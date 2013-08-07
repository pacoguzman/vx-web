# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :github_repo, :class => 'Github::Repo' do
    user
    organization_login nil
    full_name          "MyString"
    is_private          false
    ssh_url            "MyString"
    html_url           "MyString"

    trait :organization do
      organization 'Org Name'
    end
  end
end
