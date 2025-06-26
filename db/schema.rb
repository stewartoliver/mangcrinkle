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

ActiveRecord::Schema[7.1].define(version: 2025_06_14_000007) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.integer "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_id"
    t.bigint "crinkle_package_id"
    t.text "product_quantities"
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["crinkle_package_id"], name: "index_cart_items_on_crinkle_package_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "website"
    t.text "address"
    t.string "phone"
    t.string "email"
    t.json "business_hours"
    t.text "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_companies_on_active"
    t.index ["email"], name: "index_companies_on_email"
    t.index ["name"], name: "index_companies_on_name"
  end

  create_table "content_blocks", force: :cascade do |t|
    t.string "key", null: false
    t.string "title", null: false
    t.text "content"
    t.string "content_type", default: "text"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "page_locations", default: [], array: true
    t.datetime "last_used_at"
    t.string "preview_url"
    t.index ["content_type"], name: "index_content_blocks_on_content_type"
    t.index ["key"], name: "index_content_blocks_on_key", unique: true
  end

  create_table "crinkle_packages", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "price"
    t.integer "quantity"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "line_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.integer "quantity"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "purchasable_type", null: false
    t.bigint "purchasable_id", null: false
    t.text "product_quantities"
    t.index ["order_id"], name: "index_line_items_on_order_id"
    t.index ["purchasable_type", "purchasable_id"], name: "index_line_items_on_purchasable"
  end

  create_table "order_notes", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.text "content", null: false
    t.string "admin_user", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_order_notes_on_created_at"
    t.index ["order_id"], name: "index_order_notes_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "customer_name"
    t.string "email"
    t.string "phone"
    t.text "address"
    t.string "status"
    t.decimal "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total_price"
    t.bigint "user_id"
    t.string "tracking_number"
    t.string "shipping_carrier"
    t.date "estimated_delivery"
    t.datetime "shipped_at"
    t.datetime "delivered_at"
    t.string "order_source", default: "website"
    t.index ["delivered_at"], name: "index_orders_on_delivered_at"
    t.index ["order_source"], name: "index_orders_on_order_source"
    t.index ["shipped_at"], name: "index_orders_on_shipped_at"
    t.index ["tracking_number"], name: "index_orders_on_tracking_number"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "price"
    t.string "image"
    t.boolean "active"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_products_on_category"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "order_id"
    t.string "customer_name", null: false
    t.string "email", null: false
    t.integer "rating", null: false
    t.text "content", null: false
    t.boolean "approved", default: false
    t.boolean "featured", default: false
    t.text "admin_notes"
    t.datetime "approved_at"
    t.bigint "approved_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved"], name: "index_reviews_on_approved"
    t.index ["approved_by_id"], name: "index_reviews_on_approved_by_id"
    t.index ["created_at"], name: "index_reviews_on_created_at"
    t.index ["email"], name: "index_reviews_on_email"
    t.index ["featured"], name: "index_reviews_on_featured"
    t.index ["order_id"], name: "index_reviews_on_order_id"
    t.index ["rating"], name: "index_reviews_on_rating"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_type", default: "customer"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.text "address"
    t.boolean "newsletter_subscribed", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["newsletter_subscribed"], name: "index_users_on_newsletter_subscribed"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_type"], name: "index_users_on_user_type"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "crinkle_packages"
  add_foreign_key "cart_items", "products"
  add_foreign_key "line_items", "orders"
  add_foreign_key "order_notes", "orders"
  add_foreign_key "orders", "users"
  add_foreign_key "reviews", "orders"
  add_foreign_key "reviews", "users"
  add_foreign_key "reviews", "users", column: "approved_by_id"
end
