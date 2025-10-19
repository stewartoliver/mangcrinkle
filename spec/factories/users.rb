FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    user_type { "customer" }
    first_name { "John" }
    last_name { "Doe" }
    phone { "+1234567890" }
    address { "123 Main Street, Anytown, ST 12345" }
    
    trait :admin do
      user_type { "admin" }
      activated_at { Time.current }
      password { "password123" }
      password_confirmation { "password123" }
    end
    
    trait :customer do
      user_type { "customer" }
    end
  end
end
