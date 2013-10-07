class PrepareBuildConsumer

  include Evrone::Common::AMQP::Consumer

  exchange 'ci.web.builds.prepare'
  queue    'ci.web.builds.prepare'
  ack      true

  content_type "text/plain"

  def perform(build_id)
    Rails.logger.tagged("PREPARE BUILD #{build_id}") do
      build = Build.find_by id: build_id
      if build
        Buil

      end
      BuildUpdater.new(message).perform
    end
    ack!
  end

end
