module Github
  UserSession = Struct.new(:auth_info) do

    def create
      find_user || create_user
    end

    private

      def create_user
        User.transaction do

          uid   = auth_info.uid
          name  = auth_info.info.name
          token = auth_info.credentials.token
          email = auth_info.info.email || "github#{uid}@empty"
          login = auth_info.info.nickname

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
        identity = UserIdentity.provider(:gitlab).find_by(uid: auth_info.uid)
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

