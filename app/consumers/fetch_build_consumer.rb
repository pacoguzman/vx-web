class FetchBuildConsumer

  include Vx::Common::AMQP::Consumer

  exchange 'vx.web.builds.fetch'
  queue    'vx.web.builds.fetch'
  ack      true

  content_type "text/plain"

  def perform(build_id)
    ::Rails.logger.tagged("fetch build #{build_id}") do
      ::BuildFetcher.new(build_id).perform
    end
    ack!
  end

end
