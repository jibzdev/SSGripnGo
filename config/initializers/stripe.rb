# Stripe Configuration
Rails.application.config.after_initialize do
  begin
    if StripeSetting.exists?
      stripe_setting = StripeSetting.first
      if stripe_setting&.secret_key.present?
        Stripe.api_key = stripe_setting.secret_key
        Rails.logger.info("Stripe API key configured successfully")
      else
        Rails.logger.warn("Stripe secret key is not set. Please configure in admin panel.")
      end
    else
      Rails.logger.warn("No Stripe settings found. Please run rails db:seed or configure in admin panel.")
    end
  rescue => e
    Rails.logger.error("Failed to configure Stripe: #{e.message}")
  end
end
