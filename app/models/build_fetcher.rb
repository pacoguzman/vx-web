class BuildFetcher

  include Github::BuildFetcher

  attr_reader :params

  def initialize(payload_hash = {})
    @params = payload_hash
  end

  def create_perform_build_message
    create_perform_build_message_using_github
  end

end
