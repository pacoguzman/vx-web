module Github

  Organization = Struct.new(:id, :login, :user, :repositories) do

    def to_s ; login end
    def name ; login end

    def self.fetch(user)
      user.github.then do
        organizations.map do |org|
          Github::Organization.new(*org.slice("id", "login").values)
        end.map do |org|
          Thread.new do
            org.user = user
            ::User.connection_pool.with_connection do
              org.repositories = Github::Repo.fetch_for_organization(org)
            end
            org
          end.tap do |th|
            th.abort_on_exception = true
          end
        end.map(&:value).reject do |org|
          org.repositories.empty?
        end
      end || []
    end

  end
end
