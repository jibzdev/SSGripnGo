class CreateVehicleGroupsAndGroupServicePrices < ActiveRecord::Migration[7.0]
  def change
    create_table :vehicle_groups do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.decimal :default_multiplier, precision: 5, scale: 2, default: 1.0
      t.integer :position, default: 0
      t.boolean :active, default: true
      t.text :matching_rules
      t.timestamps
    end

    add_index :vehicle_groups, :code, unique: true
    add_index :vehicle_groups, :active

    create_table :group_service_prices do |t|
      t.references :service, null: false, foreign_key: true
      t.references :vehicle_group, null: false, foreign_key: true
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :currency, default: 'GBP'
      t.timestamps
    end

    add_index :group_service_prices,
              %i[service_id vehicle_group_id],
              unique: true,
              name: 'index_group_service_prices_on_service_and_group'

    change_table :bookings, bulk: true do |t|
      t.references :vehicle_group, foreign_key: true
      t.string :vehicle_group_name
      t.decimal :vehicle_group_price, precision: 10, scale: 2
    end
  end
end

