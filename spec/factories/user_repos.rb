# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_repo do
    identity           { create :user_identity }
    company_id         1
    organization_login nil
    full_name          "MyString"
    is_private          false
    ssh_url            "MyString"
    html_url           "MyString"
    external_id        1

    trait :github do
      html_url 'https://github.com'
      identity { create :user_identity, :github }
    end

    trait :gitlab do
      html_url { 'https://gitlab.example.com' }
      identity { create :user_identity, :gitlab }
    end

    trait :organization do
      organization 'Org Name'
    end
  end
end
