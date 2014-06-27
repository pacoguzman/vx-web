class UserIdentitySerializer < ActiveModel::Serializer

  attributes :id, :provider, :version, :login, :url

end
