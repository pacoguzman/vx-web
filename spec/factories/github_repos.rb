# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :github_repo, :class => 'Github::Repo' do
    organization_login "MyString"
    full_name          "MyString"
    is_private          false
    ssh_url            "MyString"
    http_url           "MyString"
  end
end
