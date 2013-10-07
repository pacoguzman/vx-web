# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name          "ci-worker-test-repo"
    http_url      "MyString"
    clone_url     "MyString"
    description   ""
    provider      "github"
    token         'token'
    deploy_key    'deploy key'

    trait :github do
      provider 'github'
    end
  end
end
