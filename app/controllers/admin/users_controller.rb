module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :edit, :update, :destroy, :remove_2fa]

    def index
      @users = User.order(created_at: :desc).page(params[:page]).per(25)
    end

    def show
      @user_orders = @user.orders.order(created_at: :desc)
    end

    def edit
      load_supporting_data
    end

    def update
      attributes = user_params
      if attributes[:password].blank?
        attributes.delete(:password)
        attributes.delete(:password_confirmation)
      end

      if @user.update(attributes)
        redirect_to edit_admin_user_path(@user), notice: 'User updated.'
      else
        load_supporting_data
        flash.now[:alert] = @user.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path, alert: 'You cannot delete your own account.' and return
      end
      @user.destroy
      redirect_to admin_users_path, notice: 'User deleted.'
    end

    def remove_2fa
      @user.update(google_secret: nil)
      redirect_to edit_admin_user_path(@user), notice: 'Two-factor authentication removed.'
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def load_supporting_data
      @ip_logs = @user.ip_logs.order(login_time: :desc).limit(50)
    end

    def user_params
      params.require(:user).permit(
        :username,
        :email,
        :password,
        :password_confirmation,
        :status,
        :receive_email_notifications,
        :admin,
        :stripe_customer_id
      )
    end
  end
end

