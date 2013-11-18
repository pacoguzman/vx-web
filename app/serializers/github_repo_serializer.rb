class GithubRepoSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :html_url, :subscribed, :repo_exists

  def repo_exists
    !!object.project
  end
end
