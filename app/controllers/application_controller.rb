class ApplicationController < ActionController::Base
    helper_method :current_user, :user_signed_in?, :admin?, :current_basket, :basket_item_count

    def upload_image
        if params[:file].present?
          url = ImageUploadService.upload(params[:file])
          render json: { url: url }, status: :ok
        else
          render json: { error: 'No file provided' }, status: :unprocessable_entity
        end
    end

    def delete_image
        if params[:key].present?
          ImageUploadService.delete(params[:key])
          render json: { message: 'Image deleted successfully' }, status: :ok
        else
          render json: { error: 'No image key provided' }, status: :unprocessable_entity
        end
    end

    def upload_seo_image
      if params[:file].present?
        url = ImageUploadService.upload(params[:file])
        if params[:seo_setting_id].present?
          seo_setting = SeoSetting.find(params[:seo_setting_id])
          seo_setting.update(image_url: url)
          render json: { url: url }, status: :ok
        else
          render json: { error: 'SEO setting ID not provided' }, status: :unprocessable_entity
        end
      else
        render json: { error: 'No file provided' }, status: :unprocessable_entity
      end
    end

    before_action :update_last_active
    before_action :check_maintenance_mode
    before_action :require_profile_completion
    before_action :hydrate_active_basket

    private

    def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      rescue ActiveRecord::RecordNotFound
        session[:user_id] = nil
    end

    def user_signed_in?
        !current_user.nil?
    end

    def admin?
        current_user&.admin?
    end

    def update_last_active
        if user_signed_in?
            current_user.update(last_active_at: Time.current)
        end
    end

    def check_maintenance_mode
      @general_setting = GeneralSetting.first_or_initialize
      if @general_setting.maintenance_mode && (!current_user || !current_user.admin?)
        redirect_to root_path, alert: "Site is currently under maintenance. Please try again later."
      end
    end

    def require_profile_completion
      return unless user_signed_in?

      # Allow access to profile completion and auth pages without redirect loops
      allowed_paths = [
        info_path,
        dashboard_account_path,
        logout_path,
        verify_email_page_path,
        resend_verification_email_path,
        auth_2fa_path,
        enable_2fa_path,
        verify_2fa_path,
      ]

      return if current_user.profile_complete?

      # Only enforce for verified users; unverified users are handled by require_email_verification
      return unless current_user.status == 'verified'

      # Skip if we're already on an allowed path or it's a non-HTML request
      current_path = request.path
      return if allowed_paths.include?(current_path)
      return unless request.format.html?

      redirect_to info_path, alert: 'Please complete your profile information to continue.'
    end

    def require_login
      unless user_signed_in?
        redirect_to login_path, notice: "You must be logged in to access this section"
      end
    end

    def require_email_verification
      if user_signed_in? && current_user.status != 'verified'
        # Allow access to profile completion so new users can finish onboarding
        return if request.path == info_path
        redirect_to verify_email_page_path, alert: "Please verify your email address to access the dashboard"
      end
    end

    def check_admin
      unless current_user&.admin?
        redirect_to dashboard_path, alert: "You must be an admin to access this section"
      end
    end

    def require_admin
      unless current_user&.admin?
        redirect_to root_path, alert: 'Access denied. Admin privileges required.'
      end
    end

    def log_activity(description)
      if current_user
        Activity.create(user: current_user, description: description)
      end
    end

    def log_ip_activity
      if current_user
        client_ip = request.headers['X-Forwarded-For'] || request.remote_ip
        IpLog.create(user: current_user, ip_address: client_ip, login_time: Time.current)
      end
    end

    def current_basket
      return @current_basket if defined?(@current_basket)

      basket = Basket.active.find_by(id: session[:basket_id])
      basket ||= Basket.create!(
        user: current_user,
        session_id: guest_session_id,
        currency: 'GBP'
      )

      if user_signed_in? && basket.user_id != current_user.id
        basket.update(user: current_user)
      end

      session[:basket_id] = basket.id
      @current_basket = basket
    rescue ActiveRecord::RecordInvalid
      @current_basket = nil
    end

    def basket_item_count
      current_basket&.basket_items&.sum(:quantity) || 0
    end

    def hydrate_active_basket
      return unless request.format.html?
      current_basket
    rescue ActiveRecord::RecordNotFound
      session[:basket_id] = nil
    end

    def guest_session_id
      session[:guest_session_id] ||= SecureRandom.uuid
    end
end
