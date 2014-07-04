require 'securerandom'

FactoryGirl.define do
  factory :build do
    id       { SecureRandom.uuid }
    project
    number   1
    branch   "MyString"
    sha      "91405d6c13b48904694f67f7abc29ef08a825728"
    author   "MyString"
    message  "MyString"
    source({ script: "true" }.to_yaml)

    trait :errored do
      after(:create) { |build| build.error! }
    end

    factory :build_errored, traits: [:errored]
  end
end
