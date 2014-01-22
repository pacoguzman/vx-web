# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project_subscription do
    project
    user { |rec| rec.project.user_repo.user }
  end
end
