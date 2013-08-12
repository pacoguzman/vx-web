class EventsController < ApplicationController
  include ActionController::Live
  include RedisSubscribe

  def index
    response.headers["Content-Type"] = "text/event-stream"

    subscribe do |event, data|
      response.stream.write("event: #{event}\n")
      response.stream.write("data: #{data}\n\n")
    end
  ensure
    response.stream.close
  end
end
