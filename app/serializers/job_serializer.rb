class JobSerializer < ActiveModel::Serializer
  attributes :id, :build_id, :project_id, :number, :status,
    :matrix, :started_at, :finished_at, :text_logs_url

  def project_id
    object.build.project_id
  end

  def status
    object.status_name
  end

  def number
    [object.build.number, object.number].join('.')
  end

  def text_logs_url
    api_job_logs_path(object, format: "txt")
  end
end
