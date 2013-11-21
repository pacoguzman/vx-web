class BuildSerializer < ActiveModel::Serializer
  attributes :id, :project_id, :number, :status, :started_at, :finished_at,
             :sha, :branch, :author, :author_email, :message, :http_url

  def status
    object.status_name
  end

  def branch
    object.branch_label || object.branch
  end
end
