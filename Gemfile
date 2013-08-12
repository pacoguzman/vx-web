source 'https://rubygems.org'

gem 'rails', '4.0.0'
gem 'pg'
gem 'redis'

gem 'haml'
gem 'haml-rails'
gem 'omniauth'
gem 'puma'
gem 'state_machine'

# github integration
gem 'omniauth-github'
gem 'octokit'
gem 'sshkey'

gem 'evrone-common-amqp', github: 'evrone/evrone-common-amqp'
gem 'evrone-ci-message',  github: 'evrone/evrone-ci-message'

group :assets do
  gem 'execjs'
  gem 'sass-rails', '~> 4.0.0'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.0.0'
end

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'factory_girl_rails'
end

group :test do
  gem 'rr'
  gem 'webmock'
  gem 'timecop'
end

group :development do
  gem 'pry'
  gem 'pry-rails'
  gem 'annotate'
  gem 'foreman'
end
