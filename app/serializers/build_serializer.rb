class BuildSerializer < BuildStatusSerializer
  attributes :sha, :branch, :author, :author_email, :message, :http_url

  def branch
    object.branch_label || object.branch
  end
end
