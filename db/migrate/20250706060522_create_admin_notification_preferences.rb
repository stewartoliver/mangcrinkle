class CreateAdminNotificationPreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_notification_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :new_order_notifications
      t.boolean :weekly_sales_report
      t.boolean :monthly_sales_report
      t.boolean :contact_form_notifications

      t.timestamps
    end
  end
end
