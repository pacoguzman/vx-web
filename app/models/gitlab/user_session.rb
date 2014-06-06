require 'faraday'
require 'json'
require 'uri'

#HttpLog.options[:log_headers] = true

module Gitlab

  # TODO: add specs
  # TODO: cleanup
  class UserSession

    attr_reader :login, :password, :host

    def initialize(params = {})
      @login    = params[:login]
      @password = params[:password]
      @host     = params[:url]
    end

    def uri
      @uri ||= URI(host)
    end

    def update_identity(identity)
      if valid?
        if response = authenticate
          if version = gitlab_version(response.private_token)
            identity.update(
              provider:  "gitlab",
              login:     response.email || response.login,
              token:     response.private_token,
              uid:       response.id,
              version:   version,
              url:       host
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
              provider: "gitlab",
              login:    response.email || response.login,
              token:    response.private_token,
              uid:      response.id,
              url:      host,
              version:  version
            )
            identity.save && identity
          end
        end
      end
    end

    def valid?
      login && password && host && true
    end

    def authenticate
      conn = Faraday.new request_options
      res = conn.post do |req|
        req.url "/api/v3/session.json"
        req.headers['Content-Type'] = 'application/json'
        req.body = { email: login, password: password }.to_json
      end
      if res.success?
        OpenStruct.new JSON.parse(res.body)
      end
    end

    private

      def https?
        uri.scheme == 'https'
      end

      def request_options
        options = { url: uri.to_s }

        if https?
          options.merge!(ssl: { verify: false })
        end

        options
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
