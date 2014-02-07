class JobLogSerializer < ActiveModel::Serializer
  attributes :id, :job_id, :tm, :log

  def log
    object.data
  end
end
