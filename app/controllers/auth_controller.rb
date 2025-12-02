class AuthController < ApplicationController
  before_action :ensure_pending_2fa, only: [:two_factor_auth, :verify_2fa_login]
  before_action :check_maintenance_mode, only: [:register_handle, :login_handle]

  def google_auth
    service = GoogleSignInService.new(google_auth_callback_url)
    redirect_to service.authorization_url, allow_other_host: true
  end

  def google_auth_callback
    service = GoogleSignInService.new(google_auth_callback_url)
    tokens = service.fetch_tokens(params[:code])

    if tokens.blank? || tokens['access_token'].blank?
      redirect_to login_path, alert: 'Google sign-in was cancelled or failed.'
      return
    end

    user_info = service.fetch_user_info(tokens['access_token'])
    
    if user_info.blank?
      redirect_to login_path, alert: 'Unable to retrieve user information from Google.'
      return
    end

    if user_info['email'].present?
      user = User.find_or_initialize_by(email: user_info['email'])

      if user.new_record?
        # Generate a unique username from Google name or email
        base_username = user_info['name']&.parameterize || user_info['email'].split('@').first
        username = base_username
        counter = 1
        
        # Ensure username is unique
        while User.exists?(username: username)
          username = "#{base_username}#{counter}"
          counter += 1
        end
        
        user.username = username
        user.password = SecureRandom.hex(18)
        user.status = 'verified' # Auto-verify Google sign-in users
        user.verification_token = nil # Clear verification token since email is verified by Google
        user.verification_sent_at = nil
        user.save!
        
        session[:user_id] = user.id
        log_activity('User registered and logged in via Google')
        log_ip_activity
        
        if user.info_complete?
          redirect_to dashboard_path, notice: 'Successfully signed in with Google'
        else
          redirect_to info_path, notice: 'Please complete your profile information.'
        end
      else
        # Check if user has 2FA enabled
        if user.google_secret.present?
          session[:pending_user_id] = user.id
          redirect_to auth_2fa_path
        else
          # For existing users, ensure they're verified if they signed in with Google
          if user.status != 'verified'
            user.update!(status: 'verified', verification_token: nil, verification_sent_at: nil)
          end
          
          session[:user_id] = user.id
          log_activity('User logged in via Google')
          log_ip_activity
          redirect_to dashboard_path, notice: 'Successfully signed in with Google'
        end
      end
    else
      redirect_to login_path, alert: 'Unable to retrieve user information from Google.'
    end
  end

  def login
    @login_seo = SeoSetting.find_by(page_name: 'login')
    @general_setting = GeneralSetting.first_or_initialize
    if user_signed_in?
      redirect_to dashboard_path
    end
  end

  def login_handle
    @general_setting = GeneralSetting.first_or_initialize
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      if @general_setting.maintenance_mode && !user.admin?
        flash[:alert] = 'Logins are currently disabled due to maintenance.'
        redirect_to root_path
      else
        if user.google_secret.present?
          session[:pending_user_id] = user.id
          redirect_to auth_2fa_path
        else
          complete_login(user)
        end
      end
    else
      redirect_to login_path, alert: 'Invalid email or password.'
    end
  end

  def verify_2fa_login
    user = User.find_by(id: session[:pending_user_id])
    
    if user.nil?
      redirect_to login_path, alert: 'Invalid session. Please login again.'
      return
    end

    if user.google_authentic?(params[:otp_code])
      session.delete(:pending_user_id)
      complete_login(user)
    else
      redirect_to auth_2fa_path, alert: 'Invalid authentication code.'
    end
  end

  def register
    @register_seo = SeoSetting.find_by(page_name: 'register')
    @general_setting = GeneralSetting.first_or_initialize
    if user_signed_in?
      redirect_to dashboard_path
    end
  end

  def register_handle
    @user = User.new(user_params)
  
    if GeneralSetting.first_or_initialize.maintenance_mode
      redirect_to login_path, alert: 'Registrations are currently disabled due to maintenance.'
      return
    end
  
    if User.exists?(username: @user.username)
      flash[:alert] = 'Username already taken'
      return redirect_to register_path
    elsif User.exists?(email: @user.email)
      flash[:alert] = 'Email already registered'
      return redirect_to register_path
    end
  
    unless params[:user][:password] == params[:user][:password_confirmation]
      flash[:alert] = 'Passwords do not match'
      return redirect_to register_path
    end
  
    if @user.save
      session[:user_id] = @user.id
      @user.generate_verification_token!
      log_activity('User registered and logged in')
      log_ip_activity
      redirect_to info_path, notice: 'Please fill in your information.'
      
      # Send verification email with error handling (skip for Google Sign In users)
      unless @user.signed_up_via_google?
        begin
          if defined?(UserMailer) && !Rails.env.test?
            UserMailer.verification_email(@user).deliver_now
          end
        rescue => e
          Rails.logger.error "Failed to send verification email: #{e.message}"
          # Don't fail the registration process if email fails
        end
      end
    else
      flash[:alert] = @user.errors.full_messages.join(', ')
      redirect_to register_path
    end
  end
  
  def forgot_password
    @forgot_password_seo = SeoSetting.find_by(page_name: 'forgot_password')
    @general_setting = GeneralSetting.first_or_initialize
  end

  def forgot_password_handle
    user = User.find_by(email: params[:email])
    if user
      user.generate_password_token!
      
      # Send forgot password email with error handling
      begin
        if defined?(UserMailer) && !Rails.env.test?
          UserMailer.forgot_password(user).deliver_now
        end
      rescue => e
        Rails.logger.error "Failed to send forgot password email: #{e.message}"
        # Continue with the process even if email fails
      end
      
      redirect_to forgot_password_sent_path, notice: 'Password reset link has been sent to your email.'
    else
      redirect_to forgot_password_path, alert: 'Email not found.'
    end
  end

  def forgot_password_sent
    @general_setting = GeneralSetting.first_or_initialize
    unless flash[:notice]
      redirect_to forgot_password_path
    end
  end

  def edit_reset_password
    @general_setting = GeneralSetting.first_or_initialize
    @token = params[:token]
    user = User.find_by(reset_password_token: @token)

    if user&.password_token_valid?
      render :reset_password
    else
      redirect_to forgot_password_path, alert: 'Link has expired or is invalid.'
    end
  end

  def update_reset_password
    @token = params[:token]
    @user = User.find_by(reset_password_token: @token)

    if @user&.password_token_valid?
      if params[:password] != params[:password_confirmation]
        return redirect_to edit_reset_password_path(token: @token), alert: 'Passwords do not match'
      end

      if @user.reset_password!(params[:password])
        log_activity('User reset password')
        redirect_to login_path, notice: 'Password has been reset successfully.'
      else
        redirect_to edit_reset_password_path(token: @token), alert: @user.errors.full_messages.join(', ')
      end
    else
      redirect_to forgot_password_path, alert: 'Link has expired or is invalid.'
    end
  rescue => e
    Rails.logger.error "Error in update_reset_password: #{e.message}"
    redirect_to edit_reset_password_path(token: @token), alert: 'An error occurred while resetting your password. Please try again.'
  end

  def logout
    user = current_user
    reset_session
    log_activity('User logged out') if user
    redirect_to root_path, notice: 'Logged out successfully.'
  end

  def verify_email
    user = User.find_by(verification_token: params[:token])
    if user&.verification_token_valid?
      user.verify_email!
      redirect_to dashboard_path, notice: 'Email verified successfully.'
      
      # Send welcome email with error handling
      begin
        if defined?(UserMailer) && !Rails.env.test?
          UserMailer.welcome_email(user).deliver_now
        end
      rescue => e
        Rails.logger.error "Failed to send welcome email: #{e.message}"
        # Don't fail the verification process if email fails
      end
    else
      redirect_to root_path, alert: 'Verification link has expired or is invalid.'
    end
  end

  def verify_email_page
    @user = current_user
    @general_setting = GeneralSetting.first_or_initialize
    
    # Redirect to login if user is not authenticated
    unless @user
      redirect_to login_path, alert: 'Please log in to verify your email.'
      return
    end
    
    # Redirect to dashboard if user is already verified
    redirect_to dashboard_path if @user.status == 'verified'
  end

  def resend_verification_email
    user = current_user

    # Skip verification for Google Sign In users
    if user.signed_up_via_google?
      redirect_to dashboard_path, notice: 'Your email is already verified through Google Sign In.'
      return
    end

    if user.verification_token_valid?
      if user.verification_sent_at && Time.current < user.verification_sent_at + 2.minutes
        time_left = ((user.verification_sent_at + 2.minutes) - Time.current).to_i
        redirect_to verify_email_page_path, alert: "Please wait #{time_left} seconds before resending the verification email."
      else
        user.generate_verification_token!
        user.update(verification_sent_at: Time.current)
        
        # Send verification email with error handling
        begin
          if defined?(UserMailer) && !Rails.env.test?
            UserMailer.verification_email(user).deliver_now
          end
        rescue => e
          Rails.logger.error "Failed to send verification email: #{e.message}"
          # Continue with the process even if email fails
        end
        
        redirect_to verify_email_page_path, notice: 'Verification email sent successfully. Please check your inbox.'
      end
    else
      user.generate_verification_token!
      user.update(verification_sent_at: Time.current)
      
      # Send verification email with error handling
      begin
        if defined?(UserMailer) && !Rails.env.test?
          UserMailer.verification_email(user).deliver_now
        end
      rescue => e
        Rails.logger.error "Failed to send verification email: #{e.message}"
        # Continue with the process even if email fails
      end
      
      redirect_to verify_email_page_path, notice: 'Verification email sent successfully. Please check your inbox.'
    end
  rescue => e
    Rails.logger.error "Error in resend_verification_email: #{e.message}"
    redirect_to verify_email_page_path, alert: 'An error occurred while resending the verification email.'
  end

  def logout_and_register
    reset_session
    redirect_to register_path
  end

  def two_factor_auth
    @general_setting = GeneralSetting.first_or_initialize
    
    unless session[:pending_user_id]
      redirect_to login_path, alert: 'Please login first.'
      return
    end
    
    render '2fa'
  end

  private

  def google_auth_callback_url
    callback_path = ENV['GOOGLE_OAUTH_CALLBACK_PATH'].presence ||
                    (Rails.env.production? ? '/auth/google_oauth2/callback' : '/auth/google/callback')

    base_url =
      if Rails.env.production?
        protocol = ENV['APP_PROTOCOL'].presence || 'https'
        host = ENV.fetch('APP_HOST', request.host_with_port)
        "#{protocol}://#{host}"
      else
        request.base_url
      end

    "#{base_url.chomp('/')}#{callback_path}"
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  def complete_login(user)
    user.update_columns(inactive: false)
    session[:user_id] = user.id
    log_activity('User logged in')
    log_ip_activity
    
    if user.info_complete?
      redirect_to dashboard_path, notice: 'Login successful. Welcome back!'
    else
      redirect_to info_path, alert: 'Please complete your profile information.'
    end
  end

  def ensure_pending_2fa
    unless session[:pending_user_id]
      redirect_to login_path, alert: 'Invalid authentication attempt.'
    end
  end
end
