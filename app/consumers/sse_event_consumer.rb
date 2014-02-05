class SseEventConsumer

  include Vx::Consumer

  exchange 'vx.web.sse'
  queue    exclusive: true
  fanout
  ack

  content_type "application/json"

  model Hash

end
