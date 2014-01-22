class UserRepoSerializer < ActiveModel::Serializer
  cached

  attributes :id, :full_name, :html_url, :subscribed, :disabled

  def disabled
    other_project = Project.where(name: object.full_name).exists?
    !!(!object.subscribed && other_project)
  end

  def subscribed
    !!(object.subscribed || object.project)
  end
end
