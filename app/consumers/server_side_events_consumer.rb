class ServerSideEventsConsumer

  include Vx::Consumer

  exchange 'vx.web.sse'
  queue    exclusive: true
  fanout

  content_type "application/json"

  def perform(payload)
    ActiveSupport::Notifications.instrument("server_side_event.internal", payload)
  end
end
