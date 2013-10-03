# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :job_log do
    job
    tm Time.new(2012, 11, 10, 9, 45).to_i
    tm_usec 12345
    data "MyText\n"
  end
end
