class FetchBuildConsumer

  include Evrone::Common::AMQP::Consumer

  exchange 'ci.web.builds.fetch'
  queue    'ci.web.builds.fetch'
  ack      true

  content_type "text/plain"

  def perform(build_id)
    ::Rails.logger.tagged("FETCH BUILD #{build_id}") do
      build = ::Build.find_by id: build_id.to_i
      if build
        ::BuildFetcher.new(build).process
      end
    end
    ack!
  end

end
