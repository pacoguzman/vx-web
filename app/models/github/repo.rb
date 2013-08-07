class Github::Repo < ActiveRecord::Base

  validates :full_name, :is_private, :ssh_url, :user_id,
    :html_url, presence: true
  validates :full_name, uniqueness: { scope: [:user_id] }

  belongs_to :user


  class << self

    def fetch_for_organization(organization)
      organization.user.github.then do
        organization_repositories(organization).reject do |repo|
          not repo.permissions.admin
        end.map do |repo|
          Github::Repo.build_from_attributes repo,
            organization: organization
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
      Github::Repo.new(
        ActionController::Parameters.new(
          attrs.slice('full_name', 'private', 'ssh_url', 'html_url')
        ).tap do |a|
          a[:is_private] = a.delete(:private)
        end.permit!
      ).tap do |repo|
        case
        when options[:organization]
          repo.organization_login = options[:organization].login
          repo.user = options[:organization].user
        when options[:user]
          repo.user = options[:user]
        end
      end
    end

  end
end
