ENV['GITHUB_KEY']    =  "ad432f8f87446b244ac5"
ENV['GITHUB_SECRET'] =  "61ff6307b2e73e7dc32953ed8b07894545a264be"

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
