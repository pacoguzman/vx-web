require 'ostruct'

Rails.configuration.x.braintree = OpenStruct.new
if ENV['BRAINTREE_MERCHANT_ID'] && ENV['BRAINTREE_PUBLIC_KEY'] && ENV['BRAINTREE_PRIVATE_KEY']
  puts " --> activate Braintree"
  Rails.configuration.x.braintree.enabled = true
  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT_ID']
  Braintree::Configuration.public_key  = ENV['BRAINTREE_PUBLIC_KEY']
  Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE_KEY']
else
  Rails.configuration.x.braintree.enabled = false
end
