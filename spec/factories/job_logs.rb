# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :job_log do
    job
    tm 1
    data "MyText\n"
  end
end
