class Api::EventsController < Api::BaseController
  include ActionController::Live

  skip_before_filter :default_format_json

  def index
    ServerSideEventLoop.new(response).start
  end
end
