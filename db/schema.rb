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

ActiveRecord::Schema[7.1].define(version: 2025_10_18_005501) do
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

  create_table "admin_notification_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "new_order_notifications"
    t.boolean "weekly_sales_report"
    t.boolean "monthly_sales_report"
    t.boolean "contact_form_notifications"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_admin_notification_preferences_on_user_id"
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

  create_table "contact_messages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "subject"
    t.text "message"
    t.string "status"
    t.string "priority"
    t.datetime "responded_at"
    t.string "admin_user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contact_messages_on_user_id"
  end

  create_table "contact_responses", force: :cascade do |t|
    t.bigint "contact_message_id", null: false
    t.string "admin_user"
    t.text "response"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_message_id"], name: "index_contact_responses_on_contact_message_id"
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
    t.date "effective_date"
    t.boolean "is_active", default: true
    t.index ["content_type"], name: "index_content_blocks_on_content_type"
    t.index ["key", "is_active"], name: "index_content_blocks_on_key_and_is_active"
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
    t.boolean "holiday_package", default: false, comment: "Whether this is a holiday-specific package"
    t.date "holiday_start_date"
    t.date "holiday_end_date"
    t.index ["holiday_package"], name: "index_crinkle_packages_on_holiday_package"
  end

  create_table "email_templates", force: :cascade do |t|
    t.string "name"
    t.string "subject"
    t.text "body"
    t.string "template_type"
    t.boolean "active"
    t.text "variables"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.interval "duration"
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.uuid "locked_by_id"
    t.datetime "locked_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key", "created_at"], name: "index_good_jobs_on_concurrency_key_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
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
    t.index ["purchasable_id", "purchasable_type"], name: "index_line_items_on_purchasable_id_and_purchasable_type"
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
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["delivered_at"], name: "index_orders_on_delivered_at"
    t.index ["order_source"], name: "index_orders_on_order_source"
    t.index ["phone"], name: "index_orders_on_phone"
    t.index ["shipped_at"], name: "index_orders_on_shipped_at"
    t.index ["tracking_number"], name: "index_orders_on_tracking_number"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "package_products", force: :cascade do |t|
    t.bigint "package_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 0, comment: "Default quantity for this product in the package"
    t.boolean "required", default: false, comment: "Whether this product is required in the package"
    t.boolean "active", default: true, comment: "Whether this product is available for selection in this package"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_package_products_on_active"
    t.index ["package_id", "product_id"], name: "index_package_products_on_package_id_and_product_id", unique: true
    t.index ["product_id"], name: "index_package_products_on_product_id"
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
    t.text "short_description"
    t.string "primary_image_id"
    t.text "ingredients"
    t.text "allergen_info"
    t.text "storage_instructions"
    t.index ["category"], name: "index_products_on_category"
    t.index ["primary_image_id"], name: "index_products_on_primary_image_id"
  end

  create_table "review_invites", force: :cascade do |t|
    t.bigint "order_id"
    t.string "email", null: false
    t.string "name", null: false
    t.string "token", null: false
    t.datetime "expires_at"
    t.datetime "used_at"
    t.datetime "sent_at"
    t.text "admin_notes"
    t.string "invite_type", default: "order", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_review_invites_on_email"
    t.index ["expires_at"], name: "index_review_invites_on_expires_at"
    t.index ["invite_type"], name: "index_review_invites_on_invite_type"
    t.index ["order_id"], name: "index_review_invites_on_order_id"
    t.index ["token"], name: "index_review_invites_on_token", unique: true
    t.index ["used_at"], name: "index_review_invites_on_used_at"
  end

  create_table "review_spam_trackers", force: :cascade do |t|
    t.string "ip_address", null: false
    t.string "email", null: false
    t.text "user_agent"
    t.integer "attempt_count", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_review_spam_trackers_on_created_at"
    t.index ["email"], name: "index_review_spam_trackers_on_email"
    t.index ["ip_address"], name: "index_review_spam_trackers_on_ip_address"
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
    t.string "title", limit: 100
    t.index ["approved"], name: "index_reviews_on_approved"
    t.index ["approved_by_id"], name: "index_reviews_on_approved_by_id"
    t.index ["created_at"], name: "index_reviews_on_created_at"
    t.index ["email"], name: "index_reviews_on_email"
    t.index ["featured"], name: "index_reviews_on_featured"
    t.index ["order_id"], name: "index_reviews_on_order_id"
    t.index ["rating"], name: "index_reviews_on_rating"
    t.index ["title"], name: "index_reviews_on_title"
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
    t.datetime "activated_at"
    t.string "activation_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["newsletter_subscribed"], name: "index_users_on_newsletter_subscribed"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_type"], name: "index_users_on_user_type"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_notification_preferences", "users"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "crinkle_packages"
  add_foreign_key "cart_items", "products"
  add_foreign_key "contact_messages", "users"
  add_foreign_key "contact_responses", "contact_messages"
  add_foreign_key "line_items", "orders"
  add_foreign_key "order_notes", "orders"
  add_foreign_key "orders", "users"
  add_foreign_key "package_products", "crinkle_packages", column: "package_id"
  add_foreign_key "package_products", "products"
  add_foreign_key "review_invites", "orders"
  add_foreign_key "reviews", "orders"
  add_foreign_key "reviews", "users"
  add_foreign_key "reviews", "users", column: "approved_by_id"
end
