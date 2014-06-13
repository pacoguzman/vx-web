# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invite do
    company_id 1
    token "MyString"
    email "MyString"
  end
end
