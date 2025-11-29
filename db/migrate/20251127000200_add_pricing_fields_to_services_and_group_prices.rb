class AddPricingFieldsToServicesAndGroupPrices < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :pricing_type, :string, null: false, default: 'fixed'
    add_column :services, :min_price, :decimal, precision: 10, scale: 2
    add_column :services, :max_price, :decimal, precision: 10, scale: 2
    add_column :services, :card_allowed, :boolean, null: false, default: true

    add_column :group_service_prices, :min_price, :decimal, precision: 10, scale: 2
    add_column :group_service_prices, :max_price, :decimal, precision: 10, scale: 2

    add_column :bookings, :vehicle_group_price_min, :decimal, precision: 10, scale: 2
    add_column :bookings, :vehicle_group_price_max, :decimal, precision: 10, scale: 2
  end
end

