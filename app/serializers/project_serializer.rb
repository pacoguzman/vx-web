class ProjectSerializer < ActiveModel::Serializer

  attributes :id, :name, :http_url, :description, :last_build_at, :created_at,
    :source, :token

  has_one  :owner
  has_many :last_builds, serializer: ::LastBuildSerializer

  def last_build_at
    if b = last_builds.first
      b.created_at
    end
  end

  def last_builds
    @last_builds ||= begin
      if scope && scope.respond_to?(:last_builds)
        scope.last_builds[object.id] || []
      else
        object.last_builds
      end
    end
  end

  def owner
    object.user
  end

  def source
    object.identity && object.identity.provider.capitalize
  end

end
