# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :artifact do
    build_id 1
    file "MyString"
    content_type "MyString"
    file_size "MyString"
    file_name "MyString"
  end
end
