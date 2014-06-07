module UserSession
  Github = Struct.new(:auth_info) do

    def find
      identity = UserIdentity.provider(:github).find_by(uid: uid)
      identity && identity.user
    end

    def create(email, options = {})

      if user = find
        user.email = email if options[:trust_email]
        user.save
        user
      else
        user =   ::User.find_by(email: email) if options[:trust_email]
        user ||= ::User.new

        user.transaction do
          user.update(email: email, name: name)
          user.identities.build(
            provider: "github",
            url:      'https://github.com',
            uid:      uid,
            token:    token,
            login:    login,
          ).save.or_rollback_transaction
        end
        user
      end
    end

    private

      def uid
        auth_info.respond_to?(:uid) && auth_info.uid
      end

      def name
        if auth_info.respond_to?(:info) && auth_info.info.respond_to?(:name)
          auth_info.info.name
        end
      end

      def token
        if auth_info.respond_to?(:credentials) && auth_info.credentials.respond_to?(:token)
          auth_info.credentials.token
        end
      end

      def login
        if auth_info.respond_to?(:info) && auth_info.info.respond_to?(:nickname)
          auth_info.info.nickname
        end
      end

  end
end
