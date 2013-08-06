# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name "MyString"
    url "MyString"
    description ""
    provider "github"
  end
end
