FactoryBot.define do
  factory :product do
    name { "Test Product" }
    description { "A test product description" }
    price { 9.99 }
    image { "test-image.jpg" }
    active { true }
    category { "Crinkles" }
    
    trait :extras do
      category { "Extras" }
    end
    
    trait :merch do
      category { "Merch" }
    end
  end
end
