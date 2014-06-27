class CurrentUserSerializer < UserSerializer

  attributes :sse_path, :role, :project_subscriptions, :current_company

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

  def current_company
    object.default_company.try(:id)
  end

  def sse_path
    "/api/events/#{object.default_company.id}"
  end

  def avatar
    gavatar_url(object.email, size: 128)
  end

end
