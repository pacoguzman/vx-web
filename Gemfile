source 'https://rubygems.org'

gem 'rails', '4.0.10'
gem 'pg'

gem 'haml-rails'
gem 'omniauth-github'
gem 'puma'
gem 'state_machine'
gem 'active_model_serializers'
gem 'carrierwave'
gem 'sshkey'

# vx-builder dependencies
gem 'vx-lib-message',       :github => 'pacoguzman/vx-message'
gem 'vx-common',            :github => 'pacoguzman/vx-common', :branch => 'bebanjo'

gem 'vx-builder',           :github => 'pacoguzman/vx-builder',           :branch => 'bebanjo'
gem 'vx-service_connector', :github => 'pacoguzman/vx-service_connector', :branch => 'bebanjo'
gem 'vx-consumer',          :github => 'pacoguzman/vx-consumer'
gem 'vx-instrumentation',   :github => 'pacoguzman/vx-instrumentation',   :tag => 'v0.1.4'

gem 'vx-common-spawn',     :github => 'pacoguzman/vx-common-spawn'
gem 'vx-lib-rack-builder', :github => 'pacoguzman/vx-common-rack-builder'

gem 'dalli'
gem 'dotenv'
gem 'braintree'

group :assets do
  gem 'sass-rails', '~> 4.0.0'
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
  gem 'nokogiri'
end

group :development do
  gem 'annotate'
  gem 'foreman'
end
