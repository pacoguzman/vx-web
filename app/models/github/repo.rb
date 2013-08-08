class Github::Repo < ActiveRecord::Base

  validates :full_name, :ssh_url, :user_id, :html_url, presence: true
  validates :is_private, inclusion: { in: [true, false] }
  validates :full_name, uniqueness: { scope: [:user_id] }

  belongs_to :user, class_name: "::User"

  default_scope ->{ order("github_repos.full_name ASC") }

  def as_json(*args)
    {
      id: id,
      full_name: full_name,
      html_url: html_url,
      subscribed: subscribed
    }
  end

  def subscribe
    transaction do

      update_attribute(:subscribed, true).or_rollback_transaction

      unless project?
        create_project.or_rollback_transaction
      end

      user.add_deploy_key_to_github_project(project).or_rollback_transaction
      user.add_hook_to_github_project(project).or_rollback_transaction

      true
    end
  end

  def unsubscribe
    transaction do

      update_attribute(:subscribed, false).or_rollback_transaction

      if project?
        project.generate_deploy_key
        project.generate_token
        project.save.or_rollback_transaction

        user.remove_hook_from_github_project(project).or_rollback_transaction
        user.remove_deploy_key_from_github_project(project).or_rollback_transaction
      end

      true
    end
  end

  def project
    @project ||= ::Project.github.find_by(name: full_name)
  end
  alias :project? :project

  private

    def create_project
      attrs = {
        name:        full_name,
        http_url:    html_url,
        clone_url:   ssh_url,
        provider:    'github',
        description: description
      }
      project = ::Project.create(attrs)
      project.persisted? && project
    end

  class << self

    def fetch_for_organization(user, organization)
      user.github.then do |g|
        g.organization_repositories(organization).reject do |repo|
          not repo.permissions.admin
        end.map do |repo|
          Github::Repo.build_from_attributes user, repo, organization: organization
        end
      end || []
    end

    def fetch_for_user(user)
      user.github.then do |g|
        g.repositories.map do |repo|
          Github::Repo.build_from_attributes user, repo
        end
      end || []
    end

    def build_from_attributes(user, attrs, options = {})
      full_name = attrs['full_name']

      user.github_repos.where(full_name: full_name).first_or_initialize.tap do |repo|
        ActionController::Parameters.new(
          attrs.slice('full_name', 'private', 'ssh_url', 'html_url', 'description')
        ).tap do |a|
          a[:is_private] = a.delete(:private)
        end.permit!.tap do |attributes|
          repo.assign_attributes attributes
          repo.user               = user
          repo.organization_login = options[:organization].try(:login)
        end
      end

    end

  end
end
