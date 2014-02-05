class EventsController < ApplicationController
  include ActionController::Live

  def index
    ServerSideEventLoop.new(response).start
  end
end
