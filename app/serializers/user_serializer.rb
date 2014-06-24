require 'digest/md5'

class UserSerializer < ActiveModel::Serializer
  include GavatarHelper

  cached

  attributes :id, :email, :name, :project_subscriptions, :default_company,
    :available_roles, :role, :sse_path, :avatar_url, :active_projects

  has_many :identities
  has_many :companies

  def role
    object.role(scope) if scope
  end

  def available_roles
    UserCompany::ROLES
  end

  def project_subscriptions
    object.active_project_subscriptions.map do |s|
      s.project_id
    end
  end

  def default_company
    object.default_company.try(:id)
  end

  def sse_path
    "/api/events/#{object.default_company.id}"
  end

  def avatar_url
    gavatar_url(object.email, size: 20)
  end

  def active_projects
    object.user_repos.in_company(scope).where(subscribed: true).count
  end
end
