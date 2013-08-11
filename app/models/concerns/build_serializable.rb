module BuildSerializable

  def as_json(*args)
    {
      id:          id,
      project_id:  project_id,
      number:      number,
      sha:         sha,
      finished_at: finished_at,
      started_at:  started_at,
      status:      status_name,
      branch:      branch
    }
  end

end
