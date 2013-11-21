class BuildFetcher

  include Github::BuildFetcher

  attr_reader :build_id

  def initialize(build_id)
    @build_id = build_id
  end

  def build
    @build ||= ::Build.find_by id: build_id
  end

  def project
    build && build.project
  end

  def perform
    if build
      create_perform_build_message_using_github
      subscribe_author_to_repo
    end
  end

  def subscribe_author_to_repo
    email = build.author_email
    if email
      ProjectSubscription.subscribe_by_email(email, project)
    end
  end

end
