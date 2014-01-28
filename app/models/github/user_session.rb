module Github
  UserSession = Struct.new(:auth_info) do

    def create
      if auth_info.try(:uid)
        find_user || create_user
      end
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
            user.update(name: name).or_rollback_transaction
          end

          identity = user.identities.find_or_initialize_by(uid: uid, provider: 'github')
          identity.update(
            token: token,
            user:  user,
            login: login,
            url:   'https://github.com'
          ).or_rollback_transaction

          if orgs = Rails.configuration.x.github_restriction
            orgs.any? do |org|
              identity.sc.organizations.include?(org)
            end.or_rollback_transaction
          end

          user
        end
      end

      def find_user
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

