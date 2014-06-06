module UserSession
  Github = Struct.new(:auth_info) do

    def find_user
      if auth_info_uid?

        identity = UserIdentity.provider(:github).find_by(uid: auth_info.uid)
        token    = auth_info.credentials.token
        login    = auth_info.info.nickname
        if identity.update(token: token, login: login)
          identity && identity.user
        end
      end
    end

    def create_user(email, company)
      if auth_info_uid?
        User.transaction do

          uid   = auth_info.uid
          name  = auth_info.info.name
          token = auth_info.credentials.token
          login = auth_info.info.nickname

          user = ::User.find_or_initialize_by(email: email)
          if user.new_record?
            user.name = name
          end
          user.save.or_rollback_transaction

          user_company = user.user_companies.find_or_initialize_by(
            company_id: company.id
          )
          if user_company.new_record?
            user_company.save.or_rollback_transaction
          end
          user_company.default!

          identity = user.identities.find_or_initialize_by(
            provider: "github",
            url:      'https://github.com',
            uid:      uid
          )
          identity.update_attributes(
            token:    token,
            user:     user,
            login:    login,
          ).or_rollback_transaction

          if orgs = Rails.configuration.x.github_restriction
            orgs.any? do |org|
              identity.sc.organizations.include?(org)
            end.or_rollback_transaction
          end

          user
        end
      end
    end

    def auth_info_uid?
      auth_info.respond_to?(:uid)
    end

  end
end
