class WsPublishConsumer

  include Evrone::Common::AMQP::Consumer

  exchange 'ci.web.ws'
  queue    'ci.web.ws'
  ack      false

  content_type "application/json"

  model Hash

  def perform(message)
    channel = message["channel"]
    event   = message["event"]
    payload = message['payload']

    Pusher[channel].trigger event, payload
  end

end
