require 'faraday'
#require 'httplog'
require 'json'

#HttpLog.options[:log_headers] = true

module Gitlab

  # TODO: add specs
  class UserSession

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

    def initialize(params = {})
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

    def create
      if valid?
        if response = authenticate
          find_user(response) || create_user(response)
        end
      end
    end

    def update_identity(identity)
      if valid?
        if response = authenticate
          if version = gitlab_version(response.private_token)
            identity.update(
              login:   response.login,
              token:   response.private_token,
              uid:     response.id,
              version: version
            )
          end
        end
      end
    end

    def create_identity(user)
      if valid?
        if response = authenticate
          if version = gitlab_version(response.private_token)
            identity = user.identities.build(
              login:   response.login,
              token:   response.private_token,
              uid:     response.id,
              version: version
            )
            identity.save
          end
        end
      end
    end

    private

      def valid?
        email && password && uri
      end

      def authenticate
        if uri
          conn = Faraday.new request_options
          res = conn.post do |req|
            req.url "/api/v3/session.json"
            req.headers['Content-Type'] = 'application/json'
            req.body = { email: email, password: password }.to_json
          end
          if res.success?
            OpenStruct.new JSON.parse(res.body)
          end
        end
      end

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
            provider: "gitlab",
            url:      uri.to_s
          )

          if identity.new_record?
            identity.version = gitlab_version(token)
          end

          identity.update(
            uid:      uid,
            token:    token,
            user:     user,
            login:    login
          ).or_rollback_transaction

          user
        end
      end

      def gitlab_version(token)
        conn = Faraday.new request_options
        res = conn.get do |req|
          req.url "/api/v3/internal/check"
          req.headers['Content-Type'] = 'application/json'
          req.headers['PRIVATE-TOKEN'] = token
        end
        if res.success?
          json = JSON.parse(res.body)
          json["gitlab_version"]
        end
      end

  end
end
