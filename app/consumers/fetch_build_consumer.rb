class FetchBuildConsumer

  include Evrone::Common::AMQP::Consumer

  exchange 'ci.web.builds.fetch'
  queue    'ci.web.builds.fetch'
  ack      true

  content_type "text/plain"

  def perform(build_id)
    ::Rails.logger.tagged("fetch build #{build_id}") do
      ::BuildFetcher.new(build_id).perform
    end
    ack!
  end

end
