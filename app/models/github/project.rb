module Github::Project

  extend ActiveSupport::Concern

  included do
    scope :github, -> { where provider: :github }
  end

  def create_build_from_github_payload(payload)
    attrs = {
      pull_request_id: payload.pull_request_number,
      branch: payload.branch,
      sha: payload.head,
    }

    build = builds.build(attrs)
    build.save && build
  end

end
