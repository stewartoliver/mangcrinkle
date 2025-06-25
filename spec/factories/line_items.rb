FactoryBot.define do
  factory :line_item do
    order { nil }
    product { nil }
    quantity { 1 }
    price { "9.99" }
  end
end
