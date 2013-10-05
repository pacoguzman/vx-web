class JobLogSerializer < ActiveModel::Serializer
  attributes :id, :job_id, :tm, :data
end
