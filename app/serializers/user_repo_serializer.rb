class UserRepoSerializer < ActiveModel::Serializer

  attributes :id, :full_name, :html_url, :subscribed, :disabled,
    :settings_url, :provider_title, :description

  def disabled
    !object.subscribed && same_name_projects?
  end

  def subscribed
    !!(object.subscribed || object.project || same_name_projects?)
  end

  def same_name_projects?
    if @same_name_projects.nil?
      @same_name_projects ||= begin
        if scope.respond_to?(:same_name_projects)
          scope.same_name_projects.include?(object.full_name)
        else
          object.same_name_projects?
        end
      end
    else
      @same_name_projects
    end
  end
end
