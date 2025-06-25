FactoryBot.define do
  factory :order do
    customer_name { "MyString" }
    email { "MyString" }
    phone { "MyString" }
    address { "MyText" }
    status { "MyString" }
    total { "9.99" }
  end
end
