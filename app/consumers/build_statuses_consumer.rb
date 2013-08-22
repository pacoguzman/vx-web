class BuildStatusesConsumer

  include Evrone::Common::AMQP::Consumer

  exchange 'ci.builds.status'
  queue    'ci.web.builds.status'
  ack      true

  def perform(payload)
    msg = Evrone::CI::Message::BuildStatus.parse payload
    Rails.logger.tagged("BUILD #{msg.build_id}") do
      BuildUpdater.new(msg).perform
    end
    ack!
  end

end
