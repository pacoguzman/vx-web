module Github

  Repository = Struct.new(:full_name, :private, :ssh_url, :permissions) do

    def self.fetch_for_organization(organization)
      organization.user.github.then do
        organization_repositories(organization).map do |repo|
          Github::Repository.create_from_attributes repo
        end.reject do |repo|
          not repo.permissions.admin
        end
      end || []
    end

    def self.fetch_for_user(user)
      user.github.then do
        repositories.map do |repo|
          Github::Repository.create_from_attributes repo
        end
      end || []
    end

    def self.create_from_attributes(attrs)
      Github::Repository.new(
        *attrs.slice('full_name', "private", "ssh_url", "permissions").values
      )
    end

  end
end
