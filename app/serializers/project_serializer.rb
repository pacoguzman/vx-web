class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :http_url, :description, :last_build_status
end
