require 'securerandom'

FactoryGirl.define do

  sequence :email do |n|
    "email#{n}@example.com"
  end

  sequence :name do |n|
    "name#{n}"
  end

  factory :user do
    id    { SecureRandom.uuid }
    email
    name
  end
end
