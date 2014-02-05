class SseEventsController < ApplicationController
  include ActionController::Live

  def index
    ServerSideEventLoop.new(response).start
  end
end
