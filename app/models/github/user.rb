module Github::User

  extend ActiveSupport::Concern

  included do
  end

  def github
    if github?
      @github ||= create_github_session
    end
  end

  def github?
    @is_github ||= identities.provider?(:github)
  end

  private

    def create_github_session
      identities.find_by_provider(:github).then do
        Octokit::Client.new(login: login, oauth_token: token)
      end
    end

  module ClassMethods

    def from_github(auth)
      find_from_github(auth) || create_from_github(auth)
    end

    private

      def create_from_github(auth)
        transaction do
          uid   = auth.uid
          name  = auth.info.name
          token = auth.credentials.token
          email = auth.info.email || "github#{uid}@empty"
          login = auth.info.nickname

          user = User.create(email: email, name: name)
          user.persisted? or raise(ActiveRecord::Rollback)

          UserIdentity.create(
            provider: 'github',
            uid:      uid,
            token:    token,
            user:     user,
            login:    login
          ).persisted? or raise(ActiveRecord::Rollback)
          user
        end
      end

      def find_from_github(auth)
        UserIdentity.where(uid: auth.uid, provider: 'github').map(&:user).first
      end

  end
end
