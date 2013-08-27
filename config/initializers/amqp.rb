require 'evrone/common/amqp'

module Evrone
  module CI
    module Web
      module AMQP

        Base = Struct.new("Subscribing", :app) do
          def consumer_name
            Thread.current[:consumer_name]
          end

          def consumer_id
            Thread.current[:consumer_id]
          end

          def consumer_tag
            consumer_id ? "#{consumer_name.split('::').last} #{consumer_id}" : consumer_name
          end

          def logger
            Rails.logger
          end
        end

        class Subscribing < Base
          def call(env)
            logger.tagged(consumer_tag) do
              logger.warn "subsribing #{env[:exchange].name}"
              app.call env
              logger.warn "shutdown"
            end
          end
        end

        class Recieving < Base
          def call(env)
            logger.warn "payload recieved #{env[:payload].inspect[0...60]}..."
            app.call env
            logger.warn "commit message"
          end
        end

        class Publishing < Base
          def call(env)
            app.call env
            #logger.warn "published #{env[:message].body}"
          end
        end
      end
    end
  end
end

Evrone::Common::AMQP.configure do |c|
  c.subscribing do
    use Evrone::CI::Web::AMQP::Subscribing
  end

  c.recieving do
    use Evrone::CI::Web::AMQP::Recieving
  end

  c.publishing do
    use Evrone::CI::Web::AMQP::Publishing
  end

  c.logger = nil
  c.content_type = 'application/x-protobuf'
end
