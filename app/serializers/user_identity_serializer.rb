class UserIdentitySerializer < ActiveModel::Serializer
  cached

  attributes :id, :provider, :version, :login, :url

  def attributes
    hash = super
    hash
  end

end
