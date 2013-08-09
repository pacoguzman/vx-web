# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :build do
    project
    number   1
    branch   "MyString"
    ref      "MyString"
    author   "MyString"
    message  "MyString"
  end
end
