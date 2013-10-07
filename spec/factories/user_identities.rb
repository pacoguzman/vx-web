# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_identity, aliases: [:identity] do
    user
    provider   "github"
    token      "MyString"
    uid        "MyString"
    login      "login"

    trait :github do
      provider :github
    end
  end
end
