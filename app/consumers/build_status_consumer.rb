class BuildStatusConsumer

  include Evrone::Common::AMQP::Consumer

  exchange 'ci.builds.status'
  queue    'ci.web.builds.status'
  ack      true

  model Evrone::CI::Message::BuildStatus

  def perform(message)
    Rails.logger.tagged("build #{message.build_id}") do
      BuildUpdater.new(message).perform
    end
    ack!
  end

end
