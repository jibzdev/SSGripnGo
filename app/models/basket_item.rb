class BasketItem < ApplicationRecord
  belongs_to :basket
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  before_validation :hydrate_unit_price
  before_validation :hydrate_snapshot
  before_save :calculate_totals

  delegate :currency, to: :basket

  def increment!(count = 1)
    update!(quantity: quantity + count)
  end

  def decrement!(count = 1)
    new_quantity = quantity - count
    new_quantity <= 0 ? destroy! : update!(quantity: new_quantity)
  end

  private

  def hydrate_unit_price
    self.unit_price ||= product.price
  end

  def hydrate_snapshot
    self.product_snapshot ||= product.snapshot
  end

  def calculate_totals
    self.total_price = unit_price * quantity
  end
end

