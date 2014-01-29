class UserRepoSerializer < ActiveModel::Serializer
  cached

  attributes :id, :full_name, :html_url, :subscribed, :disabled,
    :settings_url, :provider_title

  def disabled
    other_project = Project.where(name: object.full_name).exists?
    !!(!object.subscribed && other_project)
  end

  def settings_url
    case provider
    when 'github'
      "#{html_url}/settings/hooks"
    when 'gitlab'
      "#{html_url}/hooks"
    end
  end

  def provider_title
    case provider
    when 'github'
      'Github'
    when 'gitlab'
      'Gitlab'
    end
  end

  def provider
    object.identity.provider
  end

  def subscribed
    !!(object.subscribed || object.project)
  end
end
