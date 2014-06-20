class Api::EventsController < Api::BaseController
  include ActionController::Live

  skip_before_filter :default_format_json

  def show
    ServerSideEventLoop.new(response, channel).start
  end

  private

    def channel
      "company/#{params[:id]}"
    end
end
