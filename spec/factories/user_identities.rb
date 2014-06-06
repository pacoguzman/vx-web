# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_identity, aliases: [:identity] do
    user
    provider   "github"
    token      "MyString"
    uid        "MyString"
    login      "login"
    url        "https://example.com"

    trait :github do
      url      "https://github.com"
      provider "github"
    end

    trait :gitlab do
      url      "https://gitlab.example.com"
      provider "gitlab"
      version  "6.4.3"
    end

  end
end
