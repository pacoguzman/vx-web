require 'securerandom'

FactoryGirl.define do
  factory :project do
    id            { SecureRandom.uuid }
    company
    name          "ci-worker-test-repo"
    http_url      "http://example.com"
    clone_url     "git@example.com"
    description   ""
    token         'token'
    deploy_key    'deploy key'
    user_repo     { create(:user_repo, company: company) }

    after(:build) do |project|

    end
  end
end
