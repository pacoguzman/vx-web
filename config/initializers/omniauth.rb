Rails.application.config.middleware.use OmniAuth::Builder do
  if ENV['GITHUB_KEY'] && ENV['GITHUB_SECRET']
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "user:email,repo"
  end

  configure do |config|
    config.path_prefix = '/auth'
    config.logger = Rails.logger
  end
end

if ENV['GITHUB_KEY'] && ENV['GITHUB_SECRET']
  Rails.configuration.x.github_enabled = true
else
  Rails.configuration.x.github_enabled = false
end
