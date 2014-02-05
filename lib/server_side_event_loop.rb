require 'json'
require 'thread'

class ServerSideEventLoop

  @@mutex    = Mutex.new
  @@shutdown = false

  class << self
    def consumer
      unless @consumer
        @@mutex.synchronize do
          unless @consumer
            Rails.logger.debug " --> boot ServerSideEventsConsumer"
            @consumer = ServerSideEventsConsumer.subscribe
          end
        end
      end
      @consumer
    end

    def shutdown
      @@mutex.synchronize do
        @@shutdown = true
        if @consumer
          @consumer.cancel
        end
      end
    end

    def shutdown?
      @@mutex.synchronize do
        @@shutdown
      end
    end
  end

  attr_reader :response

  def initialize(response)
    @response = response
  end

  def start
    self.class.consumer

    send_content_type

    $stdout.puts " --> start ServerSideEventLoop"

    heartbeat  = create_heartbeat_thread
    subscriber = create_subscriber

    begin
      heartbeat.join
    ensure
      unsubscribe(subscriber)
      close_stream
    end

    Rails.logger.debug " --> stop ServerSideEventLoop"
  end

  def closed?
    response.stream.closed?
  end

  def live?
    !closed? && !self.class.shutdown?
  end

  def close_stream
    response.stream.close
  end

  def send_content_type
    response.headers["Content-Type"] = 'text/event-stream;charset=UTF-8'
  end

  def create_subscriber
    ActiveSupport::Notifications.subscribe(/server_side_event/) do |event, _, _, _, payload|
      begin
        data = JSON.dump payload
        response.stream.write("event: event\n")
        response.stream.write("data: #{data}\n\n")
      rescue IOError
        Rails.logger.debug ' --> [subscriber] closed sse stream'
      end
    end
  end

  def unsubscribe(subscriber)
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  def create_heartbeat_thread
    Thread.new do
      while live?
        begin
          response.stream.write "event: noop\n\n"
          sleep 3
        rescue IOError
          Rails.logger.debug ' --> [heartbeat] closed sse stream'
        end
      end
    end
  end
end


if defined?(::Puma)
  require 'puma/server'

  $stdout.puts " --> add callback to Puma::Server#stop"

  module ::Puma
    class Server

      alias_method :orig_stop, :stop

      def stop(*args, &block)
        Thread.new do
          $stdout.puts " --> doing shutdown ServerSideEventLoop"
          ServerSideEventLoop.shutdown
        end.join
        orig_stop(*args, &block)
      end
    end
  end
end

