class SseController < ApplicationController
  include ActionController::Live

  def show
    response.headers["Content-Type"] = "text/event-stream"

    Thread.new do
      loop do
        response.stream.write "event: 0\n\n"
        sleep 1
      end
    end

    SseEventConsumer.start do |_, q|
      while !Rails.shutdown? and !response.stream.closed?
        payload, _, _ = SseEventConsumer.pop q
        if payload
          Rails.logger.info "---> Delivery sse #{payload.inspect}"
          data  = JSON.dump payload
          response.stream.write("event: sse\n")
          response.stream.write("data: #{data}\n\n")
        end
        sleep 0.2
      end
    end
  rescue IOError
    Rails.logger.info '---> Closed sse stream'
  ensure
    Rails.logger.info '---> Close sse stream'
    response.stream.close
  end
end
