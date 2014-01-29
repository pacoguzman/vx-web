# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_repo do
    identity { create :user_identity }
    organization_login nil
    full_name          "MyString"
    is_private          false
    ssh_url            "MyString"
    html_url           "MyString"
    external_id        1

    trait :organization do
      organization 'Org Name'
    end
  end
end
