require Rails.root.join("app/middlewares/consumer_middleware")

require 'vx/consumer'

Vx::Consumer.configure do |c|
  c.content_type = 'application/x-protobuf'
  c.instrumenter = ActiveSupport::Notifications
  c.on_error     = ->(e, env) {
    Vx::Instrumentation.handle_exception("consumer.web.vx", e, env)
  }
  c.use :pub, Vx::Web::ConsumerMiddleware
  c.use :sub, Vx::Web::ConsumerMiddleware
end
