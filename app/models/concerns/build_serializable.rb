module BuildSerializable

  def as_json(*args)
    options = args.extract_options!
    attrs = {
      id:          id,
      project_id:  project_id,
      number:      number,
      sha:         sha,
      finished_at: finished_at,
      started_at:  started_at,
      status:      status_name,
      branch:      branch,
      matrix:      matrix,
      jobs_count:  jobs_count,
      author:      author,
      author_email: author_email,
      message:     message
    }
    if only = options[:only]
      attrs.slice(*only)
    else
      attrs
    end

  end

end
