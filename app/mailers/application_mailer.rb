class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  default from: -> { ApplicationMailer.formatted_from_address }
  default reply_to: -> { ApplicationMailer.reply_to_email }

  # Add headers to prevent spam filtering
  before_action :set_anti_spam_headers

  class << self
    def formatted_from_address
      "#{brand_name} <#{from_email}>"
    end

    def from_email
      ENV['OUTBOUND_EMAIL_FROM'].presence ||
        ENV['SMTP_USERNAME'].presence ||
        ENV['GMAIL_EMAIL'].presence ||
        ENV['GMAIL_USERNAME'].presence ||
        'ssgripngo@gmail.com'
    end

    def reply_to_email
      general_setting_attribute(:contact_email) ||
        ENV['OUTBOUND_REPLY_TO'].presence ||
        from_email
    end

    def brand_name
      general_setting_attribute(:application_name) ||
        ENV['MAILER_BRAND_NAME'].presence ||
        'SSGrip8o'
    end

    def support_email
      general_setting_attribute(:contact_email) || from_email
    end

    def mail_domain
      from_email.split('@').last || 'ssgrip.store'
    end

    private

    def general_setting_attribute(field)
      GeneralSetting.first&.public_send(field).presence
    rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
      nil
    end
  end

  private

  def set_anti_spam_headers
    headers['X-Mailer'] = "#{self.class.brand_name} Email System"
    headers['X-Priority'] = '3'
    headers['X-MSMail-Priority'] = 'Normal'
    headers['Importance'] = 'Normal'
    headers['X-MimeOLE'] = "Produced By #{self.class.brand_name}"
    headers['List-Unsubscribe'] = "<mailto:#{self.class.support_email}>"
    headers['List-Unsubscribe-Post'] = 'List-Unsubscribe=One-Click'
    headers['X-Auto-Response-Suppress'] = 'All'
    headers['Precedence'] = 'bulk'
    headers['X-Report-Abuse'] = "Please report abuse to #{self.class.support_email}"
    headers['Return-Path'] = self.class.from_email
    headers['Message-ID'] = "<#{SecureRandom.uuid}@#{self.class.mail_domain}>"
  end
end
