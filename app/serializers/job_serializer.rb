class JobSerializer < ActiveModel::Serializer
  cached

  attributes :id, :build_id, :project_id, :number, :natural_number, :status,
    :matrix, :started_at, :finished_at, :text_logs_url, :kind

  def project_id
    object.build.project_id
  end

  def status
    object.status_name
  end

  def matrix
    object.matrix || []
  end

  def number
    [object.build.number, object.number].join('.')
  end

  def text_logs_url
    api_job_logs_path(object, format: "txt")
  end

  def natural_number
    n = object.number.to_s.rjust(10, '0')
    "#{object.build.number}.#{n}"
  end
end
