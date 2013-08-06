ENV['GITHUB_KEY']    =  "ad432f8f87446b244ac5"
ENV['GITHUB_SECRET'] =  "61ff6307b2e73e7dc32953ed8b07894545a264be"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "user,repo,gist"
end

OmniAuth.config.logger = Rails.logger
