require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'socket'
require 'ostruct'
require 'uri'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

require 'dotenv'

Dotenv.load "#{File.expand_path("../../", __FILE__)}/.env.#{Rails.env}", "/etc/vexor/Envfile"

VX_COMPONENT_NAME ||= ENV['VX_COMPONENT_NAME'] || "http"

module VxWeb
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    if Rails.env.production?
      ENV['STDOUT_LOGGER'] ||= "1"
    end
    logger = ENV['STDOUT_LOGGER'] == '1' ? Logger.new(STDOUT) : Logger.new("log/#{Rails.env}.log")
    config.logger = ActiveSupport::TaggedLogging.new(logger)

    config.autoload_paths += [
      Rails.root.join("app/consumers").to_s,
    ]

    config.i18n.enforce_available_locales = true
    config.middleware.delete "Rack::Lock"

    config.assets.precompile += %w( lib.js )

    config.preload_frameworks = true
    config.allow_concurrency = true

    config.x = OpenStruct.new

    sys_hostname =
      begin
        Socket.gethostbyname(Socket.gethostname).first
      rescue SocketError
        Socket.gethostname
      end

    config.x.hostname = (ENV['VX_HOSTNAME'] || sys_hostname || "example.com")
    if ENV['VX_HTTPS']
      config.x.hostname = URI.parse("https://#{config.x.hostname}")
    else
      config.x.hostname = URI.parse("http://#{config.x.hostname}")
    end

    config.x.disable_signup = !!ENV['VX_WEB_DISABLE_SIGNUP']

  end
end

