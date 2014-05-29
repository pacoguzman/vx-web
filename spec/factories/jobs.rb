# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :job do
    build
    number 1
    status "initialized"
    source({"script" => "true"}.to_yaml)
  end
end
