# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project_subscription do
    user
    project
  end
end
