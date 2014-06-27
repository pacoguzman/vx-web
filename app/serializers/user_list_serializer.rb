class UserListSerializer < UserSerializer
  include GavatarHelper

  attributes :role, :roles, :projects_count

  def role
    object.role(scope) if scope
  end

  def roles
    UserCompany::ROLES
  end

  def projects_count
    object.user_repos.where(subscribed: true, company: scope).count if scope
  end

  def avatar
    gavatar_url(object.email, size: 128)
  end
end
