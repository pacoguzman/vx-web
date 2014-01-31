module Vx
  module Instrumentation
    class AmqpConsumer < Subscriber

      event(/\.consumer\.amqp$/)

    end
  end
end
