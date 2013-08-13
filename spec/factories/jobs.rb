# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :job do
    number 1
    status 0
    started_at "2013-08-13 23:11:14"
    finished_at "2013-08-13 23:11:14"
  end
end
