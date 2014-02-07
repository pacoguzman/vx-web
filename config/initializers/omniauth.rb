if ENV['GITHUB_KEY'] && ENV['GITHUB_SECRET']
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "user:email,repo"
  end

  OmniAuth.config.logger = Rails.logger

  Rails.configuration.x.github_enabled = true
else
  Rails.configuration.x.github_enabled = false
end
