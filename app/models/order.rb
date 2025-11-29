class Order < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :basket, optional: true
  has_many :order_items, dependent: :destroy
  has_many :payments, dependent: :nullify

  enum status: {
    pending: 'pending',
    confirmed: 'confirmed',
    processing: 'processing',
    fulfilled: 'fulfilled',
    cancelled: 'cancelled'
  }

  enum payment_status: {
    unpaid: 'unpaid',
    awaiting_payment: 'awaiting_payment',
    paid: 'paid',
    refunded: 'refunded'
  }

  enum fulfillment_status: {
    unfulfilled: 'unfulfilled',
    in_transit: 'in_transit',
    delivered: 'delivered',
    returned: 'returned'
  }

  validates :order_number, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { user.nil? }

  before_validation :assign_order_number, on: :create
  before_validation :sync_contact_details, on: :create

  scope :recent, -> { order(created_at: :desc) }
  scope :open_orders, -> { where.not(status: :cancelled) }

  def to_param
    order_number
  end

  def assign_line_items_from_basket!(basket)
    transaction do
      basket.basket_items.includes(:product).find_each do |item|
        order_items.create!(
          product: item.product,
          product_name: item.product.name,
          sku: item.product.sku,
          quantity: item.quantity,
          unit_price: item.unit_price,
          total_price: item.total_price,
          product_snapshot: item.product_snapshot,
          delivery_window: item.product.delivery_window
        )
      end

      update!(
        basket: basket,
        subtotal: basket.subtotal,
        discount_total: basket.discount_total,
        tax_total: basket.tax_total,
        shipping_total: basket.shipping_total,
        total: basket.total,
        currency: basket.currency
      )

      basket.converted!
    end
  end

  def mark_as_paid!(payment)
    update!(
      payment_status: :paid,
      status: :confirmed,
      paid_at: payment.paid_at || Time.current
    )
  end

  def delivery_eta
    delivery_estimate.presence || order_items.first&.delivery_window || '3-5 business days'
  end

  private

  def assign_order_number
    return if order_number.present?

    loop do
      self.order_number = "SSG-#{SecureRandom.hex(3).upcase}"
      break unless Order.exists?(order_number: order_number)
    end
  end

  def sync_contact_details
    return unless user
    self.email ||= user.email
    self.phone_number ||= user.phone_number
  end
end

