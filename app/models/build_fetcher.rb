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

  private

    def identity_not_found
      raise RuntimeError, "identity on project ID=#{project.id} is not exists"
    end
end
