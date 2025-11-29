module Admin
  class StripeSettingsController < BaseController
    def index
      @stripe_setting = StripeSetting.first_or_initialize
    end

    def update
      @stripe_setting = StripeSetting.first_or_initialize
      if @stripe_setting.update(stripe_settings_params)
        redirect_to admin_stripe_settings_path, notice: 'Stripe settings saved.'
      else
        flash.now[:alert] = @stripe_setting.errors.full_messages.to_sentence
        render :index, status: :unprocessable_entity
      end
    end

    private

    def stripe_settings_params
      params.require(:stripe_setting).permit(:publishable_key, :secret_key, :webhook_secret)
    end
  end
end

