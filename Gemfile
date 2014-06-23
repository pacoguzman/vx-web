source 'https://rubygems.org'

gem 'rails', '4.1.1'
gem 'pg'

gem 'haml-rails'
gem 'omniauth-github'
gem 'puma'
gem 'aasm'
gem 'active_model_serializers'
gem 'carrierwave'
gem 'sshkey'

gem 'vx-message',           '0.5.0'
gem 'vx-builder',           :github => 'pacoguzman/vx-builder',           :branch => 'bebanjo'
gem 'vx-common',            :github => 'pacoguzman/vx-common',            :branch => 'bebanjo'
gem 'vx-service_connector', :github => 'pacoguzman/vx-service_connector', :branch => 'bebanjo'
gem 'vx-consumer',          '0.1.4'
gem 'vx-instrumentation',   '0.1.3'

gem 'dalli'
gem 'dotenv'

# Asset Pipeline
group :assets do
  gem 'execjs'
  gem 'sass-rails', '~> 4.0.3'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.0.0'
end

group :development, :test do
  gem 'debugger'
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
