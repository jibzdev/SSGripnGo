class UpdatePaymentsForOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :payments, :order, foreign_key: true
    add_column :payments, :provider, :string
    add_column :payments, :channel, :string, default: 'storefront', null: false
    add_column :payments, :paid_at, :datetime
    add_column :payments, :reference_code, :string
    add_column :payments, :receipt_url, :string
    add_column :payments, :metadata, :json, default: {}

    change_column_default :payments, :currency, 'GBP'

    remove_column :payments, :product_id, :integer if column_exists?(:payments, :product_id)

    if foreign_key_exists?(:payments, :bookings)
      remove_foreign_key :payments, :bookings
    end
    if index_exists?(:payments, :booking_id)
      remove_index :payments, :booking_id
    end
    remove_column :payments, :booking_id, :integer if column_exists?(:payments, :booking_id)
  end
end

