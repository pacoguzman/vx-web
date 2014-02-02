class ProjectSerializer < ActiveModel::Serializer
  cached

  attributes :id, :name, :http_url, :description, :status, :last_build_created_at,
    :provider_title

  def status
    object.last_build_status_name || :unknown
  end

  def provider_title
    object.user_repo.try(:provider_title)
  end

  def last_build_created_at
    object.last_build_at
  end
end
