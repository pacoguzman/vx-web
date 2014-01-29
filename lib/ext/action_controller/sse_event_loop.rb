module ActionController
  module SseEventLoop

    module Status
      extend self

      def shutdown
        Rails.logger.info '---> Shutdown see'
        @shutdown = true
      end

      def shutdown?
        !!@shutdown
      end

      def live?
        !@shutdown
      end

      def reset
        @shutdown = false
      end
    end

    def sse_event_loop
      response.headers["Content-Type"] = 'text/event-stream;charset=UTF-8'
      th = sse_heartbeat_thread
      sse_event_loop_begin
      th.join
    end

    private

      def sse_stream_live?
        Status.live? and !response.stream.closed?
      end

      def sse_event_loop_begin
        SseEventConsumer.start do |_, q|
          begin
            while sse_stream_live?
              payload, _, _ = SseEventConsumer.pop q
              if payload
                data  = JSON.dump payload
                response.stream.write("event: sse_event\n")
                response.stream.write("data: #{data}\n\n")
                sleep 0.3
              else
                sleep 1
              end
            end
          ensure
            if q
              q.purge
              q.delete if_unused: false, if_empty: false
            end
          end
        end
      rescue IOError
        Rails.logger.info '---> Closed sse stream'
      ensure
        Rails.logger.info '---> Close sse stream'
        response.stream.close
      end

      def sse_heartbeat_thread
        Thread.new do
          while sse_stream_live?
            begin
              response.stream.write "event: 0\n\n"
              sleep 3
            rescue IOError
              Rails.logger.info '---> Closed sse stream'
            end
          end
        end
      end

  end
end

if defined?(::Puma)
  puts "[PATCH] add callback to Puma::Server#stop"

  module ::Puma
    class Server

      alias_method :orig_stop, :stop

      def stop(*args, &block)
        puts "---> Shutdown ActionController::SseEventLoop"
        Thread.new { ActionController::SseEventLoop::Status.shutdown }
        orig_stop(*args, &block)
      end
    end
  end
end
