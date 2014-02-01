require 'vx/instrumentation'

module Vx
  module Web
    class HandleException
      def initialize(app)
        @app = app
      end

      def clean_env(env)
        env = env.select{|k,v| k !~ /^(action_dispatch|puma)/ }
        env['HTTP_COOKIE'] &&= env['HTTP_COOKIE'].scan(/.{80}/).join("\n")
        env
      end

      def notify(exception, env)
        Vx::Instrumentation.handle_exception(
          'handle_exception.rack',
          exception,
          clean_env(env)
        )
      end

      def call(env)
        begin
          response = @app.call(env)
        rescue Exception => ex
          notify ex, env
          raise ex
        end

        if ex = framework_exception(env)
          notify ex, env
        end

        response
      end

      def framework_exception(env)
        env['rack.exception'] || env['action_dispatch.exception']
      end

    end
  end
end
