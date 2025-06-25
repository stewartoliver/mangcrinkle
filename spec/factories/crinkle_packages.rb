FactoryBot.define do
  factory :crinkle_package do
    name { "MyString" }
    description { "MyText" }
    price { "9.99" }
    quantity { 1 }
    active { false }
  end
end
