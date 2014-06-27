require 'securerandom'

FactoryGirl.define do
  factory :user_identity, aliases: [:identity] do
    id         { SecureRandom.uuid }
    user
    provider   "github"
    token      "token"
    uid        "uid"
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
