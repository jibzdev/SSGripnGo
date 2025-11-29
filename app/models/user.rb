class User < ApplicationRecord
  UK_POSTCODE_REGEX = /\A([A-Z]{1,2}\d[A-Z\d]?\s?\d[A-Z]{2})\z/i
  has_secure_password
  acts_as_google_authenticated lookup_token: :google_secret,
                              encrypt_secrets: true,
                              drift: 30

  has_many :orders, dependent: :nullify
  has_many :baskets, dependent: :destroy
  has_many :ip_logs, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_one :review, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: true
  validates :first_name, length: { minimum: 2, maximum: 50 }, format: { with: /\A[a-zA-Z\s\-']+\z/, message: "can only contain letters, spaces, hyphens, and apostrophes" }, allow_blank: true
  validates :last_name, length: { minimum: 2, maximum: 50 }, format: { with: /\A[a-zA-Z\s\-']+\z/, message: "can only contain letters, spaces, hyphens, and apostrophes" }, allow_blank: true
  validates :phone_number,
            format: {
              with: /\A0\d{10}\z/,
              message: "must be an 11-digit UK number (e.g. 07123456789)"
            },
            allow_blank: true
  validates :postal_code,
            format: {
              with: UK_POSTCODE_REGEX,
              message: "must be a valid UK postcode (e.g. SW1A 1AA)"
            },
            allow_blank: true

  # Custom validations for profile completion
  validate :validate_profile_completion, if: :profile_completion_context?

  def profile_completion_context?
    @profile_completion_context == true
  end

  def profile_completion_context=(value)
    @profile_completion_context = value
  end

  def full_name
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    else
      username
    end
  end

  def display_name
    full_name
  end

  def initials
    if first_name.present? && last_name.present?
      "#{first_name.first.upcase}#{last_name.first.upcase}"
    else
      username.first(2).upcase
    end
  end

  def profile_completion_percentage
    required_fields = [:first_name, :last_name, :phone_number]
    completed_fields = required_fields.count { |field| send(field).present? }
    (completed_fields.to_f / required_fields.count * 100).round
  end

  def profile_complete?
    first_name.present? && last_name.present? && phone_number.present?
  end

  def shipping_address_profile
    {
      line1: address_line1,
      line2: address_line2,
      city: city,
      region: county,
      postal_code: postal_code,
      country: country
    }.transform_values(&:presence).compact
  end

  def update_shipping_profile(address_hash)
    return if address_hash.blank?

    attrs = address_hash.with_indifferent_access
    assign_attributes(
      address_line1: attrs[:line1],
      address_line2: attrs[:line2],
      city: attrs[:city],
      county: attrs[:region],
      postal_code: attrs[:postal_code],
      country: attrs[:country] || country || 'United Kingdom'
    )
    save(validate: false)
  end

  def signed_up_via_google?
    # Check if user was created via Google Sign In (no verification token and verified status)
    verification_token.blank? && status == 'verified' && password_digest.present?
  end

  def generate_verification_token!
    self.verification_token = generate_token
    self.verification_sent_at = Time.now.utc
    save!
  end

  def generate_password_token!
    self.reset_password_token = generate_token
    self.reset_password_sent_at = Time.now.utc
    save!
  end

  def password_token_valid?
    (self.reset_password_sent_at + 10.minutes) > Time.now.utc
  end

  def reset_password!(password)
    self.reset_password_token = nil
    self.password = password
    save!
  end

  def verification_token_valid?
    return false if verification_sent_at.nil?
    (self.verification_sent_at + 24.hours) > Time.now.utc
  end

  def verify_email!
    self.verification_token = nil
    self.status = "verified"
    save!
  end

  def admin?
    admin == true
  end

  def active?
    status == "verified"
  end

  def inactive?
    inactive == true
  end

  def info_complete?
    profile_complete?
  end

  def can_be_deleted?
    # Check if user has any critical data that would prevent deletion
    return false if admin? && User.where(admin: true).count <= 1
    return false if orders.where.not(status: 'cancelled').exists?
    true
  end

  def safe_destroy
    return false unless can_be_deleted?
    
    transaction do
      cleanup_associations
      destroy!
    end
    true
  rescue => e
    Rails.logger.error("Safe destroy failed for user #{id}: #{e.message}")
    errors.add(:base, "Cannot delete user: #{e.message}")
    false
  end

  private

  def validate_profile_completion
    if first_name.blank?
      errors.add(:first_name, "can't be blank")
    end
    
    if last_name.blank?
      errors.add(:last_name, "can't be blank")
    end
    
    if phone_number.blank?
      errors.add(:phone_number, "can't be blank")
    end
  end

  def current_streak
    # Calculate current streak based on login activity
    # This is a placeholder - implement based on your needs
    0
  end

  def questions_answered_correctly
    # Placeholder for question tracking
    0
  end

  def questions_answered_incorrectly
    # Placeholder for question tracking
    0
  end

  def questions_not_answered
    # Placeholder for question tracking
    0
  end

  def question_sessions
    # Placeholder for question sessions
    []
  end

  def user_products
    # Placeholder for user products/subscriptions
    []
  end

  def selected_product_id
    # Placeholder for selected product
    nil
  end

  # Add a callback to update last_active_at on each request
  before_save :update_last_active

  before_destroy :cleanup_associations

  def ensure_stripe_customer
    return if stripe_customer_id.present?

    customer = Stripe::Customer.create(email: email)
    update(stripe_customer_id: customer.id)
  end

  def generate_fresh_stripe_customer
    customer = Stripe::Customer.create(email: email)
    update(stripe_customer_id: customer.id)
  end

  def set_google_secret
    self.google_secret = ROTP::Base32.random
  end

  def google_qr_uri
    issuer = "RK Customs"
    label = "#{email}"
    ROTP::TOTP.new(google_secret, issuer: issuer).provisioning_uri(label)
  end

  def google_authentic?(code)
    return false if google_secret.blank?
    ROTP::TOTP.new(google_secret).verify(code.to_s, drift_behind: 15, drift_ahead: 15)
  end

  def open_orders
    orders.where.not(status: :cancelled).order(created_at: :desc)
  end

  def recent_orders(limit = 5)
    orders.order(created_at: :desc).limit(limit)
  end

  private

  def generate_token
    SecureRandom.hex(10)
  end

  def update_last_active
    self.last_active_at = Time.current if self.changed?
  end

  def cleanup_associations
    # Safely destroy associations with error handling
    begin
      activities.destroy_all if activities.any?
    rescue => e
      Rails.logger.error("Failed to destroy activities for user #{id}: #{e.message}")
    end
    
    begin
      ip_logs.destroy_all if ip_logs.any?
    rescue => e
      Rails.logger.error("Failed to destroy ip_logs for user #{id}: #{e.message}")
    end
    
    begin
      notifications.destroy_all if notifications.any?
    rescue => e
      Rails.logger.error("Failed to destroy notifications for user #{id}: #{e.message}")
    end
    
    begin
      payments.destroy_all if payments.any?
    rescue => e
      Rails.logger.error("Failed to destroy payments for user #{id}: #{e.message}")
    end
    
    begin
      baskets.destroy_all if baskets.any?
    rescue => e
      Rails.logger.error("Failed to destroy baskets for user #{id}: #{e.message}")
    end

    begin
      orders.update_all(user_id: nil) if orders.any?
    rescue => e
      Rails.logger.error("Failed to nullify orders for user #{id}: #{e.message}")
    end
  end
end
