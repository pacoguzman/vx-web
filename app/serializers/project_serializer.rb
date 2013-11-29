class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :http_url, :description, :status, :last_build_created_at

  def status
    object.last_build_status
  end

  def last_build_created_at
    object.last_build_created_at
  end
end
