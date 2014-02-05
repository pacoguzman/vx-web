if defined?(::Puma)
  require 'vx/consumer'
  require 'puma/server'

  $stdout.puts " --> add callback to Puma::Server#stop"

  module ::Puma
    class Server

      alias_method :orig_stop, :stop

      def stop(*args, &block)
        Thread.new do
          Rails.logger.debug " --> shutdown consumers"
          Vx::Consumer.shutdown
        end
        orig_stop(*args, &block)
      end
    end
  end
end
