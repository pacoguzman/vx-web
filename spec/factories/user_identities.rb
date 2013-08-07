# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_identity do
    user
    provider   "MyString"
    token      "MyString"
    uid        "MyString"
    login      "login"

    trait :github do
      provider :github
    end
  end
end
