require 'pusher'

pusher_key    = ENV['CI_WEB_PUSHER_KEY']    || 'guest'
pusher_secret = ENV['CI_WEB_PUSHER_SECRET'] || 'guest'
pusher_app    = ENV['CI_WEB_PUSHER_APP']    || 0

if pusher_key && pusher_secret && pusher_app
  pusher_url    = "http://#{pusher_key}:#{pusher_secret}@api.pusherapp.com/apps/#{pusher_app}"

  Pusher.url = pusher_url
  Pusher.logger = Rails.logger
end
