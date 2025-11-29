# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_11_30_020000) do
  create_table "activities", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "basket_items", force: :cascade do |t|
    t.integer "basket_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "unit_price", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_price", precision: 12, scale: 2, default: "0.0", null: false
    t.json "product_snapshot", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["basket_id", "product_id"], name: "index_basket_items_on_basket_id_and_product_id", unique: true
    t.index ["basket_id"], name: "index_basket_items_on_basket_id"
    t.index ["product_id"], name: "index_basket_items_on_product_id"
  end

  create_table "baskets", force: :cascade do |t|
    t.integer "user_id"
    t.string "session_id"
    t.string "status", default: "active", null: false
    t.string "currency", default: "GBP", null: false
    t.decimal "subtotal", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "discount_total", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "tax_total", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "shipping_total", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "expires_at"
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_baskets_on_session_id"
    t.index ["status"], name: "index_baskets_on_status"
    t.index ["user_id"], name: "index_baskets_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.string "hero_image"
    t.string "highlight_color"
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_categories_on_active"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "general_settings", force: :cascade do |t|
    t.string "application_name", default: "RKCustoms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "maintenance_mode"
    t.string "phone_number"
    t.string "contact_email"
    t.string "website_url"
    t.string "bank_account_name"
    t.string "bank_account_number"
    t.string "bank_sort_code"
    t.string "bank_iban"
    t.text "bank_instructions"
    t.string "bank_reference_hint"
  end

  create_table "ip_logs", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.datetime "login_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_ip_logs_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "message"
    t.string "notification_type"
    t.boolean "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "product_id"
    t.string "product_name", null: false
    t.string "sku"
    t.integer "quantity", default: 1, null: false
    t.decimal "unit_price", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_price", precision: 12, scale: 2, default: "0.0", null: false
    t.string "delivery_window"
    t.string "status", default: "pending", null: false
    t.json "product_snapshot", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "user_id"
    t.integer "basket_id"
    t.string "order_number", null: false
    t.string "status", default: "pending", null: false
    t.string "payment_status", default: "unpaid", null: false
    t.string "fulfillment_status", default: "unfulfilled", null: false
    t.string "currency", default: "GBP", null: false
    t.decimal "subtotal", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "discount_total", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "shipping_total", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "tax_total", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total", precision: 12, scale: 2, default: "0.0", null: false
    t.string "shipping_method"
    t.string "delivery_estimate"
    t.string "tracking_number"
    t.datetime "placed_at"
    t.datetime "paid_at"
    t.datetime "fulfilled_at"
    t.datetime "cancelled_at"
    t.string "email"
    t.string "phone_number"
    t.json "shipping_address", default: {}
    t.json "billing_address", default: {}
    t.text "notes"
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["basket_id"], name: "index_orders_on_basket_id"
    t.index ["fulfillment_status"], name: "index_orders_on_fulfillment_status"
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["payment_status"], name: "index_orders_on_payment_status"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payment_ip_logs", force: :cascade do |t|
    t.integer "payment_id", null: false
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_payment_ip_logs_on_payment_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "user_id"
    t.string "status"
    t.decimal "amount"
    t.string "payment_type"
    t.string "stripe_session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_charge_id"
    t.string "currency", default: "GBP"
    t.boolean "initial_payment", default: false
    t.string "payment_method"
    t.integer "order_id"
    t.string "provider"
    t.string "channel", default: "storefront", null: false
    t.datetime "paid_at"
    t.string "reference_code"
    t.string "receipt_url"
    t.json "metadata", default: {}
    t.index ["order_id"], name: "index_payments_on_order_id"
  end

  create_table "products", force: :cascade do |t|
    t.integer "category_id"
    t.string "name", null: false
    t.string "slug", null: false
    t.string "sku"
    t.string "status", default: "draft", null: false
    t.boolean "featured", default: false, null: false
    t.text "short_description"
    t.text "description"
    t.decimal "price", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "compare_at_price", precision: 12, scale: 2
    t.integer "stock_quantity", default: 0, null: false
    t.integer "low_stock_threshold", default: 3, null: false
    t.integer "max_per_order"
    t.string "currency", default: "GBP", null: false
    t.string "shipping_lead_time"
    t.string "delivery_message"
    t.string "hero_image"
    t.json "gallery_images", default: []
    t.json "specifications", default: {}
    t.json "metadata", default: {}
    t.datetime "published_at"
    t.string "seo_title"
    t.text "seo_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["featured"], name: "index_products_on_featured"
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["status"], name: "index_products_on_status"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "rating", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["published"], name: "index_reviews_on_published"
    t.index ["user_id"], name: "index_reviews_on_user_id", unique: true
  end

  create_table "seo_settings", force: :cascade do |t|
    t.string "page_name"
    t.string "title"
    t.text "description"
    t.string "keywords"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.string "author"
    t.string "robots", default: "index, follow"
    t.string "og_type", default: "website"
    t.string "og_url"
    t.string "og_title"
    t.text "og_description"
    t.string "og_image"
    t.string "twitter_card", default: "summary_large_image"
    t.string "twitter_url"
    t.string "twitter_title"
    t.text "twitter_description"
    t.string "twitter_image"
    t.string "favicon_url"
    t.string "apple_touch_icon_url"
    t.string "canonical_url"
    t.text "structured_data"
  end

  create_table "stripe_settings", force: :cascade do |t|
    t.string "publishable_key"
    t.string "secret_key"
    t.string "webhook_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "receive_email_notifications", default: true
    t.boolean "admin", default: false
    t.string "status", default: "unverified"
    t.string "verification_token"
    t.datetime "verification_sent_at"
    t.datetime "last_active_at"
    t.string "stripe_customer_id"
    t.string "google_secret"
    t.boolean "inactive", default: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "county"
    t.string "postal_code"
    t.string "country", default: "United Kingdom"
  end

  add_foreign_key "activities", "users"
  add_foreign_key "basket_items", "baskets"
  add_foreign_key "basket_items", "products"
  add_foreign_key "baskets", "users"
  add_foreign_key "ip_logs", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "baskets"
  add_foreign_key "orders", "users"
  add_foreign_key "payment_ip_logs", "payments"
  add_foreign_key "payments", "orders"
  add_foreign_key "products", "categories"
  add_foreign_key "reviews", "users"
end
