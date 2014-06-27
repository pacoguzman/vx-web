require 'securerandom'

FactoryGirl.define do
  factory :build do
    id       { SecureRandom.uuid }
    project
    number   1
    branch   "MyString"
    sha      "MyString"
    author   "MyString"
    message  "MyString"
    source({ script: "true" }.to_yaml)
  end
end
