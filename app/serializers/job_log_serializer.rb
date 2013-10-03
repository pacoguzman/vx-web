class JobLogSerializer < ActiveModel::Serializer
  attributes :id, :job_id, :tm, :tm_usec, :data

  def id
    object.log_id
  end
end
