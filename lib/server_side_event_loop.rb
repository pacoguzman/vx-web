ServerSideEventLoop = Struct.new(:response) do

  def start
    send_content_type

    Rails.logger.debug " --> start ServerSideEventLoop"

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
    !closed?
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
        response.stream.write("event: sse_event\n")
        response.stream.write("data: #{payload}\n\n")
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

