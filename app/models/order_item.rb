class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true

  validates :product_name, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  before_save :sync_total_price

  def display_price
    ApplicationController.helpers.number_to_currency(unit_price, unit: currency_symbol)
  end

  def currency_symbol
    case order.currency
    when 'USD' then '$'
    when 'EUR' then '€'
    else '£'
    end
  end

  private

  def sync_total_price
    self.total_price = unit_price * quantity
  end
end

