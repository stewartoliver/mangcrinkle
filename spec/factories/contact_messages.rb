FactoryBot.define do
  factory :contact_message do
    user { nil }
    subject { "MyString" }
    message { "MyText" }
    status { "MyString" }
    priority { "MyString" }
    responded_at { "2025-07-06 18:02:36" }
    admin_user { "MyString" }
  end
end
