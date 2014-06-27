require 'securerandom'

FactoryGirl.define do
  factory :job do
    id     { SecureRandom.uuid }
    build
    number 1
    status 0
    source({"script" => "true"}.to_yaml)
    kind   'regular'

    trait :deploy do
      kind 'deploy'
    end
  end
end
