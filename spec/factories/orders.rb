FactoryBot.define do
  factory :order do
    customer_name { "John Doe" }
    email { "customer@example.com" }
    phone { "+1234567890" }
    address { "123 Main Street, Anytown, ST 12345" }
    status { "pending" }
    total_price { 29.99 }
    order_source { "website" }
    
    trait :with_user do
      association :user
      customer_name { nil }
      email { nil }
      phone { nil }
      address { nil }
    end
    
    trait :completed do
      status { "completed" }
    end
    
    trait :processing do
      status { "processing" }
    end
    
    trait :cancelled do
      status { "cancelled" }
    end
  end
end
