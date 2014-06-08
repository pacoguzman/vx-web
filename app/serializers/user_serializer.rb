class UserSerializer < ActiveModel::Serializer
  cached

  attributes :id, :email, :name, :project_subscriptions, :default_company

  has_many :identities
  has_many :companies

  def project_subscriptions
    object.project_subscriptions.active.map do |s|
      s.project_id
    end
  end

  def default_company
    object.default_company.try(:id)
  end
end
