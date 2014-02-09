require 'vx/instrumentation'

module Vx
  module Web
    HandleExceptionMiddleware = Struct.new(:app) do

      IGNORED_EXCEPTIONS = %w{
        ActionController::RoutingError
      }

      def clean_env(env)
        env = env.select{|k,v| k !~ /^(action_dispatch|puma|session|rack\.session|action_controller)/ }
        env['HTTP_COOKIE'] &&= env['HTTP_COOKIE'].scan(/.{80}/).join("\n")
        env
      end

      def notify(exception, env)
        unless ignore?(exception)
          Vx::Instrumentation.handle_exception(
            'handle_rack_exception.web.vx',
            exception,
            clean_env(env)
          )
        end
      end

      def call(env)
        begin
          response = app.call(env)
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

      def ignore?(ex)
        IGNORED_EXCEPTIONS.include? ex.class.name
      end

    end
  end
end
