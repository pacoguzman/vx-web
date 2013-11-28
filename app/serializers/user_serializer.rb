class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :project_subscriptions

  has_many :identities

  def project_subscriptions
    object.project_subscriptions.active.map do |s|
      s.project_id
    end
  end
end
