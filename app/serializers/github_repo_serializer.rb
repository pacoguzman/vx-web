class GithubRepoSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :html_url, :subscribed, :disabled

  def disabled
    !!(!object.subscribed && object.project?)
  end

  def subscribed
    !!(object.subscribed || object.project?)
  end
end
