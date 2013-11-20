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
  end

end
