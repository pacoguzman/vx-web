class BuildFetcher

  include Github::BuildFetcher

  attr_reader :build

  def initialize(build)
    @build = build
  end

  def project
    build.project
  end

  def process
    create_perform_build_message_using_github
    subscribe_by_email
  end

  def subscribe_author_to_repo
    email = build.author_email
    if email
      ProjectSubscription.subscribe_by_email(email, project)
    end
  end

end
