class UserRepoSerializer < ActiveModel::Serializer

  attributes :id, :full_name, :html_url, :subscribed, :disabled,
    :settings_url, :provider_title, :description, :project_id

  def disabled
    !object.subscribed && same_name_projects?
  end

  def subscribed
    !!(object.subscribed || object.project || same_name_projects?)
  end

  def project_id
    case
    when object.project
      object.project.id
    when scope.respond_to?(:same_name_projects)
      scope.same_name_projects.select{ |p|
        p.name == object.full_name
      }.map(&:id).first
    end
  end

  def same_name_projects?
    if @same_name_projects.nil?
      @same_name_projects ||= begin
        if scope.respond_to?(:same_name_projects)
          scope.same_name_projects.map(&:name).include?(object.full_name)
        else
          object.same_name_projects?
        end
      end
    else
      @same_name_projects
    end
  end
end
