module Github::User

  extend ActiveSupport::Concern

  included do
    has_many :github_repos, dependent: :destroy,
      class_name: "::Github::Repo"
  end

  def add_hook_to_github_project!(project)
    github.then do
      config = {
        url:           project.hook_url,
        secret:        project.token,
        content_type: "json"
      }
      options = { events: %w{ push pull_request } }
      create_hook(project.name, "web", config, options)
    end
  end

  def add_deploy_key_to_github_project!(project)
    github.then do
      add_deploy_key(project.name,
                     project.deploy_key_name,
                     project.public_deploy_key)
    end
  end

  def remove_hook_from_github_project!(project)
    github.then do
      hooks(project.name).select do |hook|
        hook.config.url =~ /#{Regexp.escape Rails.configuration.x.hostname}\//
      end.map do |hook|
        remove_hook(project.name, hook.id)
      end
    end
  end

  def remove_deploy_key_from_github_project!(project)
    github.then do
      deploy_keys(project.name).select do |key|
        key.title == project.deploy_key_name
      end.map do |key|
        remove_deploy_key(project.name, key.id)
      end
    end
  end

  def github
    if github?
      @github ||= create_github_session
    end
  end

  def github?
    @is_github ||= identities.provider?(:github)
  end

  def github_organizations
    github.then { organizations } || []
  end

  def sync_github_repos!
    logger.tagged("SYNC:REPOS #{id}") do

      organizations = github_organizations.map(&:login)

      (organizations + [nil]).map do |organization|
        Thread.new do
          ::User.connection_pool.with_connection do
            if organization
              ::Github::Repo.fetch_for_organization(self, organization)
            else
              ::Github::Repo.fetch_for_user(self)
            end
          end
        end.tap do |th|
          th.abort_on_exception = true
        end
      end.map(&:value).flatten.map do |repo|
        repo.save!
        repo.id
      end.tap do |ids|
        github_repos.where("id NOT IN (?)", ids).destroy_all
      end

      ::Github::Repo.count
    end
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
