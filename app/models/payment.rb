class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :order, optional: true
  has_many :payment_ip_logs, dependent: :destroy

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_type, presence: true
  validates :currency, presence: true

  before_validation :set_defaults

  enum status: {
    pending: 'pending',
    successful: 'successful',
    cancelled: 'cancelled',
    voided: 'voided',
    refunded: 'refunded',
    requires_action: 'requires_action'
  }

  enum payment_type: {
    deposit: 'deposit',
    full_payment: 'full_payment',
    partial_payment: 'partial_payment',
    refund: 'refund'
  }

  enum payment_method: {
    card: 'card',
    cash: 'cash',
    bank_transfer: 'bank_transfer',
    wallet: 'wallet'
  }

  enum channel: {
    storefront: 'storefront',
    admin: 'admin',
    subscription: 'subscription'
  }

  scope :successful, -> { where(status: 'successful') }
  scope :pending, -> { where(status: 'pending') }
  scope :recent, -> { order(created_at: :desc) }

  def formatted_amount
    ApplicationController.helpers.number_to_currency(amount, unit: currency_symbol)
  end

  def formatted_date
    (paid_at || created_at).strftime('%B %d, %Y at %I:%M %p')
  end

  def refundable?
    successful? && !refunded?
  end

  private

  def set_defaults
    self.currency ||= 'GBP'
  end

  def currency_symbol
    case currency
    when 'USD' then '$'
    when 'EUR' then '€'
    else '£'
    end
  end
end
