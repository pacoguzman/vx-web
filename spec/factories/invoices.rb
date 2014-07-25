# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invoice do
    company
    state   0
    amount  100
  end
end
