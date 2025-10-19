FactoryBot.define do
  factory :cart_item do
    association :cart
    association :product
    quantity { 1 }
    
    trait :with_package do
      product { nil }
      association :crinkle_package
      product_quantities { { "1" => 2, "2" => 1 } }
    end
  end
end
