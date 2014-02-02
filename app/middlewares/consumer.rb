require 'vx/instrumentation'

module Vx
  module Web
    class Consumer

      def initialize(app)
        @app = app
      end

      def call(env)
        prop = env[:properties] || {}
        prop.inject({}) do |a, pair|
          key, value = pair
          a["consumer.#{key}"] = value
          a
        end

        Vx::Instrumentation.with(prop) do
          @app.call(env)
        end

      end
    end
  end
end
