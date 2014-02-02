require 'vx/instrumentation'

module Vx
  module Web
    class Consumer

      def initialize(app)
        @app = app
      end

      def call(env)
        prop = env[:properties] || {}
        head = prop[:headers] || {}

        Vx::Instrumentation.with("@fields" => head) do
          @app.call(env)
        end

      end
    end
  end
end
