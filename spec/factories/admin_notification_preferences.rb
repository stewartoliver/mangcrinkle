FactoryBot.define do
  factory :admin_notification_preference do
    user { nil }
    new_order_notifications { false }
    weekly_sales_report { false }
    monthly_sales_report { false }
    contact_form_notifications { false }
  end
end
