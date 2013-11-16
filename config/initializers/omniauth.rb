Octokit.configure do |config|
  config.auto_paginate = true
end

if %w{ development test }.include?(Rails.env)
  stack = Faraday::Builder.new do |builder|
    builder.response :logger
    builder.use Octokit::Response::RaiseError
    builder.adapter Faraday.default_adapter
  end
  Octokit.middleware = stack
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "user:email,repo"
end

OmniAuth.config.logger = Rails.logger
