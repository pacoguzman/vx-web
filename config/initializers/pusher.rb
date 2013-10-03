require 'pusher'

pusher_key    = ENV['EVRONE_CI_PUSHER_KEY'] || 'guest'
pusher_secret = ENV['EVRONE_CI_PUSHER_SECRET'] || 'guest'
pusher_app    = ENV['EVRONE_CI_PUSHER_APP'] || 0

Pusher.url = "http://#{pusher_key}:#{pusher_secret}@api.pusherapp.com/apps/#{pusher_app}"
Pusher.logger = Rails.logger
