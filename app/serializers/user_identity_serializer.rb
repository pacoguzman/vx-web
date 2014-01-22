class UserIdentitySerializer < ActiveModel::Serializer
  cached

  attributes :provider
end
