class Github::Repo < ActiveRecord::Base

  validates :full_name, :ssh_url, :user_id, :html_url, presence: true
  validates :is_private, inclusion: { in: [true, false] }
  validates :full_name, uniqueness: { scope: [:user_id] }

  belongs_to :user


  class << self

    def fetch_for_organization(organization)
      organization.user.github.then do
        organization_repositories(organization).reject do |repo|
          not repo.permissions.admin
        end.map do |repo|
          Github::Repo.build_from_attributes repo, organization: organization
        end
      end || []
    end

    def fetch_for_user(user)
      user.github.then do
        repositories.map do |repo|
          Github::Repo.build_from_attributes repo, user: user
        end
      end || []
    end

    def build_from_attributes(attrs, options = {})
      full_name = attrs['full_name']
      user      = options[:user] || options[:organization].user

      user.github_repos.where(full_name: full_name).first_or_initialize.tap do |repo|
        ActionController::Parameters.new(
          attrs.slice('full_name', 'private', 'ssh_url', 'html_url')
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
