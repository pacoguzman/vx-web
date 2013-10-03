class JobLogSerializer < ActiveModel::Serializer
  attributes :id, :job_id, :tm, :tm_usec, :data

  def id
    [object.job_id, object.tm, object.tm_usec].join('.')
  end
end
