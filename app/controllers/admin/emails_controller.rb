module Admin
  class EmailsController < BaseController
    TEMPLATE_METADATA = [
      { name: 'Welcome Email', template: 'welcome_email', description: 'Sent after a user signs up.' },
      { name: 'Order Confirmation', template: 'order_confirmation', description: 'Sent when an order has been placed.' },
      { name: 'Order Status Update', template: 'order_status_update', description: 'Keeps customers informed about their order.' },
      { name: 'Email Verification', template: 'verification_email', description: 'Used to verify new accounts.' },
      { name: 'Password Reset', template: 'forgot_password', description: 'Sent when a user requests a reset.' }
    ].freeze

    def index
      @email_templates = TEMPLATE_METADATA
    end

    def preview
      template = params[:template].to_s
      unless TEMPLATE_METADATA.any? { |meta| meta[:template] == template }
        redirect_to admin_emails_path, alert: 'Template not found.' and return
      end

      assign_sample_data
      render template: "user_mailer/#{template}", layout: 'mailer'
    end

    private

    def assign_sample_data
      @user = User.first || User.new(username: 'driver', email: 'driver@example.com')
      @order = Order.first || Order.new(order_number: 'SSG-DEMO', total: 99.99, currency: 'GBP')
      @token = 'sample-token'
    end
  end
end

