class BuildSerializer < BuildStatusSerializer
  attributes :sha, :branch, :author, :author_email, :message, :jobs_count,
    :matrix
end
