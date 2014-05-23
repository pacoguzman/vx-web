class BuildSerializer < ActiveModel::Serializer
  cached

  attributes :id, :project_id, :number, :status, :started_at, :finished_at,
             :sha, :branch, :author, :author_email, :message, :http_url, :pull_request_id,
             :project_name

  def project_name
    object.project.name
  end

  def status
    object.status_name
  end

  def branch
    object.branch_label || object.branch
  end
end
