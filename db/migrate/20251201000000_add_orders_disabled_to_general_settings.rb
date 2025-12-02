class AddOrdersDisabledToGeneralSettings < ActiveRecord::Migration[7.0]
  def change
    change_table :general_settings, bulk: true do |t|
      t.boolean :orders_disabled, default: false
      t.text :orders_disabled_reason
    end
  end
end

