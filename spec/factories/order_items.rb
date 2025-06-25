FactoryBot.define do
  factory :order_item do
    order { nil }
    cookie { nil }
    quantity { 1 }
    price { "9.99" }
  end
end
