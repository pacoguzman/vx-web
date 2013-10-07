class Github::Repo < ActiveRecord::Base

  validates :full_name, :ssh_url, :user_id, :html_url, presence: true
  validates :is_private, inclusion: { in: [true, false] }
  validates :full_name, uniqueness: { scope: [:user_id] }

  belongs_to :user, class_name: "::User"

  default_scope ->{ order("github_repos.full_name ASC") }

  def subscribe
    transaction do

      update_attribute(:subscribed, true).or_rollback_transaction

      unless project?
        new_project = create_project.or_rollback_transaction
        yield new_project if block_given?
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
        description: description,
        identity:    user.identities.github
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
      full_name = attrs[:full_name]

      user.github_repos.where(full_name: full_name).first_or_initialize.tap do |repo|
        ActionController::Parameters.new(
          attrs.to_hash.slice(:full_name, :private, :description)
        ).tap do |a|
          a[:is_private]  = a.delete(:private)
          a[:ssh_url]     = attrs.rels[:ssh].href
          a[:html_url]    = attrs.rels[:html].href
        end.permit!.tap do |attributes|
          repo.assign_attributes attributes
          repo.user               = user
          repo.organization_login = options[:organization].try(:login)
        end
      end

    end

  end
end

# == Schema Information
#
# Table name: github_repos
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  organization_login :string(255)
#  full_name          :string(255)      not null
#  is_private         :boolean          not null
#  ssh_url            :string(255)      not null
#  html_url           :string(255)      not null
#  subscribed         :boolean          default(FALSE), not null
#  description        :text
#  created_at         :datetime
#  updated_at         :datetime
#

