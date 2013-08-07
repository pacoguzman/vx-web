module Github

  Organization = Struct.new(:id, :login, :user, :repositories) do

    def to_s ; login end
    def name ; login end

    def self.fetch(user)
      user.github.then do
        organizations.map do |org|
          Github::Organization.new(*org.slice("id", "login").values)
        end.map do |org|
          org.user = user
          org.repositories = Github::Repository.fetch_for_organization(org)
          org
        end.reject do |org|
          org.repositories.empty?
        end
      end || []
    end

  end
end
