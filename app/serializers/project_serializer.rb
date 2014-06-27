class ProjectSerializer < ActiveModel::Serializer

  attributes :id, :name, :http_url, :description, :last_build_at, :created_at,
    :source

  has_one :last_build
  has_one :owner

  def last_build_at
    if b = last_build
      b.created_at
    end
  end

  def last_build
    @last_build ||= begin
      if scope && scope.respond_to?(:last_builds)
        scope.last_builds.to_a.find{|b| b.project_id == object.id }
      else
        object.last_build
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
