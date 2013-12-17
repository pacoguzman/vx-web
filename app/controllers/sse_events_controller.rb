class SseEventsController < ApplicationController
  include ActionController::Live
  include ActionController::SseEventLoop

  def index
    sse_event_loop
  end
end
