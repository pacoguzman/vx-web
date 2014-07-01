require 'digest/md5'

class UserSerializer < ActiveModel::Serializer
  include GavatarHelper

  attributes :id, :email, :name, :avatar

  def avatar
    gavatar_url(object.email, size: 38)
  end
end
