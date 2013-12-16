class BuildStatusConsumer

  include Vx::Common::AMQP::Consumer

  exchange 'vx.builds.status'
  queue    'vx.web.builds.status'
  ack      true

  model Vx::Message::BuildStatus

  def perform(message)
    Rails.logger.tagged("build #{message.build_id}") do
      BuildUpdater.new(message).perform
    end
    ack!
  end

end
