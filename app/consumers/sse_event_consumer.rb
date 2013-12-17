class SseEventConsumer

  include Vx::Common::AMQP::Consumer

  exchange 'vx.web.sse', type: :fanout # broadcast
  queue    '', exclusive: true
  ack      false

  content_type "application/json"

  model Hash

end
