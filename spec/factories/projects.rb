# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    company_id    1
    name          "ci-worker-test-repo"
    http_url      "MyString"
    clone_url     "MyString"
    description   ""
    token         'token'
    deploy_key    'deploy key'
    user_repo
  end
end
