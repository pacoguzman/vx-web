class BuildStatusSerializer < ActiveModel::Serializer
  attributes :id, :project_id, :number, :status, :started_at, :finished_at

  def status
    object.status_name
  end
end
