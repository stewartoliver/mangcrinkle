FactoryBot.define do
  factory :product do
    name { "MyString" }
    description { "MyText" }
    price { "9.99" }
    image { "MyString" }
    active { false }
    category { "MyString" }
  end
end
