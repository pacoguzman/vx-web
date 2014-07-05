class LastBuildSerializer < ActiveModel::Serializer

  attributes :id, :number, :created_at, :started_at, :duration, :status, :author

end
