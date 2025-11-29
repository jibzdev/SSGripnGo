class DashboardController < ApplicationController
  layout 'dashboard'
  before_action :require_login
  before_action :require_email_verification

  def index
    redirect_to dashboard_path
  end

  def overview
    @general_setting = GeneralSetting.first_or_initialize
    @recent_orders = current_user.orders.recent.limit(5)
    @open_orders = current_user.orders.where.not(status: :cancelled).count
    @total_spent = current_user.payments.successful.sum(:amount)
    @basket = current_basket
    @featured_products = Product.published.featured.limit(4)
    @notifications = current_user.notifications.order(created_at: :desc).limit(5)
  end

  def account
    @general_setting = GeneralSetting.first_or_initialize
    @user = current_user
    
    if request.patch?
      if params[:user][:new_password].present?
        if current_user.authenticate(params[:user][:current_password])
          if params[:user][:new_password] == params[:user][:confirm_password]
            current_user.password = params[:user][:new_password]
            current_user.password_confirmation = params[:user][:confirm_password]
          else
            current_user.errors.add(:confirm_password, "doesn't match new password")
            render :account and return
          end
        else
          current_user.errors.add(:current_password, "is incorrect")
          render :account and return
        end
      end
      
      if current_user.update(user_params.except(:current_password, :new_password, :confirm_password))
        log_activity("Updated account information")
        redirect_to dashboard_account_path, notice: 'Account updated successfully!'
      else
        render :account
      end
    else
      render :account
    end
  end

  def info
    @general_setting = GeneralSetting.first_or_initialize
    @user = current_user
    
    if request.patch?
      @user.profile_completion_context = true
      if @user.update(info_params)
        log_activity("Completed profile information")
        if @user.profile_complete? && @user.activities.where(description: "Completed profile information").count == 1
          @user.notifications.create!(
            message: "Welcome to SSGrip! Your profile is now complete. You can start ordering products and enjoy personalized recommendations.",
            notification_type: "welcome",
            read: false
          )
        end
        redirect_to dashboard_path, notice: 'Profile information completed successfully!'
      else
        render :info
      end
    else
      render :info
    end
  end

  def enable_2fa
    @general_setting = GeneralSetting.first_or_initialize
    @user = current_user
    if @user.google_secret.blank?
      @user.set_google_secret
      @secret = @user.google_secret
      @qr_code = RQRCode::QRCode.new(@user.google_qr_uri)
      session[:temp_2fa_secret] = @secret

      render 'dashboard/auth/enable_2fa'
    else
      redirect_to dashboard_account_path, notice: '2FA is already enabled.'
    end
  end

  def verify_2fa
    @user = current_user
    temp_secret = session[:temp_2fa_secret]
    
    if temp_secret.present? && @user.present?
      @user.google_secret = temp_secret
      
      if @user.google_authentic?(params[:otp_code])
        @user.update!(google_secret: temp_secret)
        session.delete(:temp_2fa_secret)
        log_activity('User enabled 2FA')
        redirect_to dashboard_account_path, notice: '2FA has been successfully enabled.'
      else
        @user.google_secret = nil
        redirect_to enable_2fa_path, alert: 'Invalid verification code. Please try again.'
      end
    else
      redirect_to enable_2fa_path, alert: 'Session expired. Please try again.'
    end
  end

  def remove_2fa
    @user = current_user
    @user.google_secret = nil
    @user.save!
    log_activity('User disabled 2FA')
    redirect_to dashboard_account_path, notice: '2FA has been successfully removed.'
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :receive_email_notifications, 
                                :current_password, :new_password, :confirm_password,
                                :first_name, :last_name, :phone_number)
  end

  def info_params
    params.require(:user).permit(:first_name, :last_name, :phone_number)
  end

end
