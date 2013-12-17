module ActionController
  module SseEventLoop

    module Status
      extend self

      def shutdown
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
      raise "28364"
      response.headers["Content-Type"] = 'text/event-stream'
      th = sse_heartbeat_thread
      sse_event_loop
      th.join
    end

    private

      def sse_stream_live?
        Status.live? and !response.stream.closed?
      end

      def sse_event_loop
        SseEventConsumer.start do |_, q|
          while sse_stream_live?
            payload, _, _ = SseEventConsumer.pop q
            if payload
              Rails.logger.info "---> Delivery sse #{payload.inspect}"
              data  = JSON.dump payload
              response.stream.write("event: sse_event\n")
              response.stream.write("data: #{data}\n\n")
              sleep 0.1
            else
              sleep 1
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
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!---"
        Thread.new do
          puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
          while sse_stream_live?
            begin
              Rails.logger.info "---> Ping"
              response.stream.write "event: 0\n\n"
              sleep 1
            rescue IOError
              Rails.logger.info '---> Closed sse stream'
            end
          end
        end
      end

  end
end

trap("TERM") { Thread.new{ ActionController::SseEventLoop::Status.shutdown } }
