class PerformBuildConsumer

  include Evrone::Common::AMQP::Consumer

  exchange 'ci.web.builds.perform'
  queue    'ci.web.builds.perform'
  ack      true

  content_type "application/json"

  model Hash

  def perform(message)
    Rails.logger.tagged("BUILD #{message.build_id}") do
      BuildUpdater.new(message).perform
    end
    ack!
  end

end
