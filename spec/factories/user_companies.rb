# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_company do
    user
    company
    default 1
    role 'developer'

    trait :admin do
      role 'admin'
    end
  end
end
