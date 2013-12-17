class WsPublishConsumer

  include Vx::Common::AMQP::Consumer

  exchange 'vx.web.ws'
  queue    'vx.web.ws'
  ack      false

  content_type "application/json"

  model Hash

  def perform(message)
    if Pusher.url && Pusher.url.user
      channel = message["channel"]
      event   = message["event"]
      payload = message['payload']

      Pusher[channel].trigger event, payload
    end
  end

end
