class Basket < ApplicationRecord
  belongs_to :user, optional: true
  has_many :basket_items, dependent: :destroy
  has_one :order

  enum status: {
    active: 'active',
    converted: 'converted',
    expired: 'expired'
  }

  validates :currency, presence: true

  before_validation :set_currency, on: :create
  before_create :set_expiration

  scope :stale, -> { where('expires_at < ?', Time.current) }

  def add_product(product, quantity: 1)
    raise ArgumentError, 'Quantity must be at least 1' if quantity.to_i < 1
    ensure_active!

    item = basket_items.find_or_initialize_by(product: product)
    item.quantity += quantity.to_i if item.persisted?
    item.quantity = quantity.to_i unless item.persisted?
    item.unit_price = product.price
    item.product_snapshot = product.snapshot
    item.save!

    recalculate_totals!
    item
  end

  def update_quantity(item_id, quantity)
    item = basket_items.find(item_id)
    if quantity.to_i <= 0
      item.destroy
    else
      item.update!(quantity: quantity)
    end

    recalculate_totals!
  end

  def empty!
    basket_items.destroy_all
    update!(subtotal: 0, total: 0, discount_total: 0, tax_total: 0, shipping_total: 0)
  end

  def recalculate_totals!
    new_subtotal = basket_items.sum(:total_price)
    self.subtotal = new_subtotal
    self.total = new_subtotal - discount_total + tax_total + shipping_total
    save!
  end

  def ensure_active!
    return if active?

    if expired?
      raise StandardError, 'This basket has expired. Please start a new basket.'
    else
      raise StandardError, 'Basket is no longer editable.'
    end
  end

  private

  def set_currency
    self.currency ||= 'GBP'
  end

  def set_expiration
    self.expires_at ||= 7.days.from_now
  end
end

