class SseEventConsumer

  include Vx::Common::AMQP::Consumer

  exchange 'vx.web.ws'
  queue    '', exclusive: true
  ack      false

  content_type "application/json"

  model Hash

end
