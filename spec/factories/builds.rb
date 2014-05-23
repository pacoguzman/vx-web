# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :build do
    project
    number   1
    branch   "MyString"
    sha      "MyString"
    author   "MyString"
    message  "MyString"
    source({ script: "true" }.to_yaml)

    trait :errored do
      after(:create) { |build| build.error! }
    end

    factory :build_errored, traits: [:errored]
  end
end
