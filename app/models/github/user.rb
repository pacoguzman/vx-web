module Github::User

  extend ActiveSupport::Concern

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

          user = ::User.create(email: email, name: name)
          user.persisted?.or_rollback_transaction

          UserIdentity.create(
            provider: 'github',
            uid:      uid,
            token:    token,
            user:     user,
            login:    login
          ).persisted?.or_rollback_transaction

          if org = Rails.configuration.x.github_restriction
            user.github_organizations.map(&:login).include?(org).or_rollback_transaction
          end

          user
        end
      end

      def find_from_github(auth)
        identity = UserIdentity.where(uid: auth.uid, provider: 'github').first
        if identity
          identity.user
        end
      end

  end
end

# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string(255)      not null
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

