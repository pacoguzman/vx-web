require 'faraday'
require 'httplog'
require 'json'

HttpLog.options[:log_headers] = true

module Gitlab
  class UserSession

    extend ActiveModel::Naming
    include ActiveModel::Conversion

    ENV_RE = /^GITLAB_URL[0-9]*$/

    attr_reader :email, :password, :host

    class << self
      def uris(env = ENV)
        @uris ||=
          env.keys.select{ |i| i =~ ENV_RE }.map do |key|
            URI(env[key])
          end
      end
    end

    def initialize(params)
      @email    = params[:email]
      @password = params[:password]
      @host     = params[:host]
    end

    def persisted?
      false
    end

    def hosts
      self.class.uris.map(&:host)
    end

    def uri
      self.class.uris.select{|u| u.host == host }.first
    end

    def body
      { email: email, password: password }
    end

    def authenticate
      if uri
        conn = Faraday.new request_options
        res = conn.post do |req|
          req.url "/api/v3/session"
          req.headers['Content-Type'] = 'application/json'
          req.body = body.to_json
        end
        if res.success?
          OpenStruct.new JSON.parse(res.body)
        end
      end
    end

    def create
      if response = authenticate
        Rails.logger.debug "Got response: #{response.inspect}"
        find_user(response) || create_user(response)
      end
    end

    private

      def https?
        uri.scheme == 'https'
      end

      def request_options
        u = uri
        options = { url: u.to_s }

        if u.scheme == 'https'
          options.merge!(ssl: { verify: false })
        end

        options
      end

      def find_user(response)
        identity = UserIdentity.provider(:gitlab).find_by(uid: response.id.to_s)
        if identity
          identity.user
        end
      end

      def create_user(response)
        User.transaction do
          uid   = response.id
          name  = response.name
          token = response.private_token
          email = response.email || "gitlab#{uid}@empty"
          login = response.username

          user = User.find_or_initialize_by(email: email)
          if user.new_record?
            user.update(name: name).or_rollback_transaction
          end

          identity = user.identities.find_or_initialize_by(
            provider: 'gitlab',
            url:      uri.to_s
          )
          identity.update(
            token:    token,
            user:     user,
            login:    login,
          ).save.or_rollback_transaction
          false.or_rollback_transaction
        end
      end

  end
end
