class BuildNotifyConsumer

  include Vx::Common::AMQP::Consumer

  exchange 'vx.web.builds.notify'
  queue    'vx.web.builds.notify'
  ack      true

  model Hash
  content_type 'application/json'

  def perform(message)
    build_id = message["id"]
    status   = message["status"]

    if build_id && status
      ::Rails.logger.tagged("notify #{build_id}.#{status}") do
        ::BuildNotifier.new(message).notify
      end
    end
    ack!
  end

end
