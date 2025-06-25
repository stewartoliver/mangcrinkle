FactoryBot.define do
  factory :cookie do
    name { "MyString" }
    description { "MyText" }
    price { "9.99" }
    image { "MyString" }
    active { false }
  end
end
