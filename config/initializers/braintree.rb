require 'ostruct'

Rails.configuration.x.braintree = false

if ENV['BRAINTREE_MERCHANT_ID'] && ENV['BRAINTREE_PUBLIC_KEY'] && ENV['BRAINTREE_PRIVATE_KEY']
  puts " --> activate Braintree"
  Rails.configuration.x.braintree = true
  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT_ID']
  Braintree::Configuration.public_key  = ENV['BRAINTREE_PUBLIC_KEY']
  Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE_KEY']
end
