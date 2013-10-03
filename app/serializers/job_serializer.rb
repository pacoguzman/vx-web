class JobSerializer < ActiveModel::Serializer
  attributes :id, :build_id, :project_id, :number, :status,
    :matrix, :started_at, :finished_at

  def project_id
    object.build.project_id
  end

  def status
    object.status_name
  end
end
