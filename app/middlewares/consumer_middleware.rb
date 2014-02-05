require 'vx/instrumentation'

module Vx
  module Web
    ConsumerMiddleware = Struct.new(:app) do

      def call(env)
        prop = env[:properties] || {}
        head = prop[:headers] || {}

        Vx::Instrumentation.with("@fields" => head) do
          app.call(env)
        end

      end
    end
  end
end
