class BuildSerializer < BuildStatusSerializer
  attributes :sha, :branch, :author, :author_email, :message, :http_url
end
