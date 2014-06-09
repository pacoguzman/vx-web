class UserSerializer < ActiveModel::Serializer
  cached

  attributes :id, :email, :name, :project_subscriptions, :default_company,
    :available_roles, :role

  has_many :identities
  has_many :companies

  def role
    object.role(scope) if scope
  end

  def available_roles
    UserCompany.roles
  end

  def project_subscriptions
    object.project_subscriptions.active.map do |s|
      s.project_id
    end
  end

  def default_company
    object.default_company.try(:id)
  end
end
