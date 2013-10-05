class GithubRepoSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :html_url, :subscribed, :updated_at
end
