class BuildSerializer < ActiveModel::Serializer
  include GavatarHelper

  cached

  attributes :id, :project_id, :number, :status, :started_at, :finished_at,
             :sha, :branch, :author, :author_email, :message, :http_url,
             :author_avatar

  def status
    object.status_name
  end

  def branch
    object.branch_label || object.branch
  end

  def author_avatar
    gavatar_url(author_email, size: 20)
  end
end
