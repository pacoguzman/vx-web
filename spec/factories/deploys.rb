# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :deploy, parent: :build, class: "::Deploy" do
    project
    number   1
    branch   "MyString"
    sha      "MyString"
    author   "MyString"
    message  "MyString"
    source({ script: "true" }.to_yaml)
  end
end
