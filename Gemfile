source 'https://rubygems.org'

gem 'rails', '4.1.6'
gem 'pg'

gem 'haml-rails'
gem 'omniauth-github'
gem 'puma'
gem 'aasm'
gem 'active_model_serializers'
gem 'carrierwave'
gem 'sshkey'

# vx-builder dependencies
gem 'vx-message',           :github => 'pacoguzman/vx-message'
gem 'vx-common',            :github => 'pacoguzman/vx-common', :branch => 'bebanjo'

gem 'vx-builder',           :github => 'pacoguzman/vx-builder',           :branch => 'bebanjo'
gem 'vx-service_connector', :github => 'pacoguzman/vx-service_connector', :branch => 'bebanjo'
gem 'vx-consumer',          :github => 'pacoguzman/vx-consumer'
gem 'vx-instrumentation',   '0.1.4'

gem 'dalli'
gem 'dotenv'
gem 'braintree'

# Asset Pipeline
group :assets do
  gem 'execjs'
  gem 'sass-rails', '~> 4.0.3'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.0.0'
end

group :development, :test do
  gem 'byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rspec-its', :require => false
  gem 'factory_girl_rails'
end

group :test do
  gem 'rr'
  gem 'webmock'
  gem 'timecop'
end

group :development do
  gem 'spring'
  gem 'annotate'
  gem 'foreman'
end
