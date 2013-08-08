# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name          "MyString"
    http_url      "MyString"
    clone_url     "MyString"
    description   ""
    provider      "github"

    trait :github do
      provider 'github'
    end
  end
end
