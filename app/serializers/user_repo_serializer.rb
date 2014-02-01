class UserRepoSerializer < ActiveModel::Serializer
  cached

  attributes :id, :full_name, :html_url, :subscribed, :disabled,
    :settings_url, :provider_title

  def disabled
    !!(!object.subscribed && object.same_name_projects.any?)
  end

  def subscribed
    !!(object.subscribed || object.project)
  end
end
