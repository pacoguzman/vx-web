class FetchBuildConsumer

  include Evrone::Common::AMQP::Consumer

  exchange 'ci.web.builds.prepare'
  queue    'ci.web.builds.prepare'
  ack      true

  content_type "text/plain"

  def perform(build_id)
    Rails.logger.tagged("FETCH BUILD #{build_id}") do
      build = Build.find_by id: build_id.to_i
      if build
        BuildFetcher.new(build)
      end
    end
    ack!
  end

end
