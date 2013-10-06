class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :http_url, :description, :status

  def status
    object.last_build_status
  end
end
