# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :job_log do
    job_id 1
    tm "2013-08-22 17:05:31"
    data "MyText"
  end
end
