# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :job do
    build
    number 1
    status 0
    source({"script" => "true"}.to_yaml)

    trait :deploy do
      kind 'deploy'
    end

  end
end
