ENV['GITHUB_KEY']    =  "ad432f8f87446b244ac5"
ENV['GITHUB_SECRET'] =  "61ff6307b2e73e7dc32953ed8b07894545a264be"

Octokit.configure do |config|
  config.auto_traversal = true
  if %w{ development test }.include?(Rails.env)
    config.faraday_config do |f|
      f.use Faraday::Response::Logger, Rails.logger
      f.use Faraday::Response::RaiseError
    end
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "user:email,repo"
end

OmniAuth.config.logger = Rails.logger
