class CreateStoreCollections < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string  :name, null: false
      t.string  :slug, null: false
      t.text    :description
      t.integer :position, default: 0, null: false
      t.boolean :active, default: true, null: false
      t.string  :hero_image
      t.string  :highlight_color
      t.json    :metadata, default: {}
      t.timestamps
    end
    add_index :categories, :slug, unique: true
    add_index :categories, :active

    create_table :products do |t|
      t.references :category, foreign_key: true
      t.string  :name, null: false
      t.string  :slug, null: false
      t.string  :sku
      t.string  :status, default: 'draft', null: false
      t.boolean :featured, default: false, null: false
      t.text    :short_description
      t.text    :description
      t.decimal :price, precision: 12, scale: 2, default: 0, null: false
      t.decimal :compare_at_price, precision: 12, scale: 2
      t.integer :stock_quantity, default: 0, null: false
      t.integer :low_stock_threshold, default: 3, null: false
      t.integer :max_per_order
      t.string  :currency, default: 'GBP', null: false
      t.string  :shipping_lead_time
      t.string  :delivery_message
      t.string  :hero_image
      t.json    :gallery_images, default: []
      t.json    :specifications, default: {}
      t.json    :metadata, default: {}
      t.datetime :published_at
      t.string   :seo_title
      t.text     :seo_description
      t.timestamps
    end
    add_index :products, :slug, unique: true
    add_index :products, :sku, unique: true
    add_index :products, :status
    add_index :products, :featured

    create_table :baskets do |t|
      t.references :user, foreign_key: true
      t.string  :session_id, index: true
      t.string  :status, default: 'active', null: false
      t.string  :currency, default: 'GBP', null: false
      t.decimal :subtotal, precision: 12, scale: 2, default: 0, null: false
      t.decimal :discount_total, precision: 12, scale: 2, default: 0, null: false
      t.decimal :tax_total, precision: 12, scale: 2, default: 0, null: false
      t.decimal :shipping_total, precision: 12, scale: 2, default: 0, null: false
      t.decimal :total, precision: 12, scale: 2, default: 0, null: false
      t.datetime :expires_at
      t.json :metadata, default: {}
      t.timestamps
    end
    add_index :baskets, :status

    create_table :basket_items do |t|
      t.references :basket, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, default: 1, null: false
      t.decimal :unit_price, precision: 12, scale: 2, default: 0, null: false
      t.decimal :total_price, precision: 12, scale: 2, default: 0, null: false
      t.json :product_snapshot, default: {}
      t.timestamps
    end
    add_index :basket_items, [:basket_id, :product_id], unique: true

    create_table :orders do |t|
      t.references :user, foreign_key: true
      t.references :basket, foreign_key: true
      t.string  :order_number, null: false
      t.string  :status, default: 'pending', null: false
      t.string  :payment_status, default: 'unpaid', null: false
      t.string  :fulfillment_status, default: 'unfulfilled', null: false
      t.string  :currency, default: 'GBP', null: false
      t.decimal :subtotal, precision: 12, scale: 2, default: 0, null: false
      t.decimal :discount_total, precision: 12, scale: 2, default: 0, null: false
      t.decimal :shipping_total, precision: 12, scale: 2, default: 0, null: false
      t.decimal :tax_total, precision: 12, scale: 2, default: 0, null: false
      t.decimal :total, precision: 12, scale: 2, default: 0, null: false
      t.string  :shipping_method
      t.string  :delivery_estimate
      t.string  :tracking_number
      t.datetime :placed_at
      t.datetime :paid_at
      t.datetime :fulfilled_at
      t.datetime :cancelled_at
      t.string  :email
      t.string  :phone_number
      t.json    :shipping_address, default: {}
      t.json    :billing_address, default: {}
      t.text    :notes
      t.json    :metadata, default: {}
      t.timestamps
    end
    add_index :orders, :order_number, unique: true
    add_index :orders, :status
    add_index :orders, :payment_status
    add_index :orders, :fulfillment_status

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, foreign_key: true
      t.string  :product_name, null: false
      t.string  :sku
      t.integer :quantity, default: 1, null: false
      t.decimal :unit_price, precision: 12, scale: 2, default: 0, null: false
      t.decimal :total_price, precision: 12, scale: 2, default: 0, null: false
      t.string  :delivery_window
      t.string  :status, default: 'pending', null: false
      t.json    :product_snapshot, default: {}
      t.timestamps
    end
  end
end

