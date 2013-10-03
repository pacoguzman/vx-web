class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :http_url, :description
end
