# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_identity do
    user
    provider   "MyString"
    token      "MyString"
    uid        "MyString"
  end
end
