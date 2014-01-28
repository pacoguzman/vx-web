module Github
  class UserSession

    def create(auth_info)
      find_user(auth_info) || create_user(auth_info)
    end

    private

      def create_user(auth)
        User.transaction do

          uid   = auth.uid
          name  = auth.info.name
          token = auth.credentials.token
          email = auth.info.email || "github#{uid}@empty"
          login = auth.info.nickname

          user = ::User.find_or_initialize_by(email: email)
          if user.new_record?
            user.update name: name
          end
          user.persisted?.or_rollback_transaction

          identity = UserIdentity.new(
            provider: 'github',
            uid:      uid,
            token:    token,
            user:     user,
            login:    login,
            url:      "https://github.com"
          )
          identity.save.or_rollback_transaction

          # TODO: add specs
          if org = Rails.configuration.x.github_restriction
            identity.service_connector.organizations.include?(org).or_rollback_transaction
          end

          user
        end
      end

      def find_user(response)
        identity = UserIdentity.provider(:gitlab).find_by(uid: auth.uid)
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

