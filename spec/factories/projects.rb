# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    company
    name          "ci-worker-test-repo"
    http_url      "MyString"
    clone_url     "MyString"
    description   ""
    token         'token'
    deploy_key    'deploy key'
    user_repo     { create(:user_repo, company: company) }

    after(:build) do |project|

    end
  end
end
