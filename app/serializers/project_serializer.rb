class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :http_url, :description, :status, :subscribed

  def status
    object.last_build_status
  end

  def subscribed
    scope && object.subscribed_by?(scope)
  end
end
