require Rails.root.join("app/middlewares/consumer")

require 'vx/common/amqp'
require 'airbrake'

Vx::Common::AMQP.configure do |c|
  c.content_type = 'application/x-protobuf'
  c.instrumenter = ActiveSupport::Notifications
  c.on_error     = ->(e, env) {
    Vx::Instrumentation.handle_exception("consumer.amqp", e, env)
    Airbrake.notify(e, env)
  }
  c.use :pub, Vx::Web::Consumer
  c.use :sub, Vx::Web::Consumer
end
