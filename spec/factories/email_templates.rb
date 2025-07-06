FactoryBot.define do
  factory :email_template do
    name { "MyString" }
    subject { "MyString" }
    body { "MyText" }
    template_type { "MyString" }
    active { false }
    variables { "MyText" }
  end
end
