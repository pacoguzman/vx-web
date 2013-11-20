module ApplicationHelper
  def build_status_name(build)
    {
      finished: "passed",
      failed: "failed",
      errored: "errored"
    }[build.status_name]
  end

  def build_status(build)
    "Build ##{build.number} #{build_status_name build}"
  end

  def public_project_url(project)
    "http://#{Rails.configuration.x.hostname}/projects/#{project.id}"
  end

  def public_build_url(build)
    "http://#{Rails.configuration.x.hostname}/builds/#{build.id}"
  end

  def build_duration(build)
    distance_of_time_in_words(build.started_at, build.finished_at, include_seconds: true)
  end

  def build_title(build)
    s = build.sha.to_s[0..8]
    s << " ("
    s << build.branch
    s << ")"
  end

  def build_author_url(build)
    link_to build.author, "mailto:#{build.author_email}"
  end

  def build_status_color(build)
    {
      finished: "#4FA06F",
      failed: "#999999",
      errored: "#BE4141"
    }[build.status_name]
  end
end
