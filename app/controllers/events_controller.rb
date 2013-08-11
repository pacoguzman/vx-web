class EventsController < ApplicationController
  include ActionController::Live

  def show
    response.headers["Content-Type"] = "text/event-stream"

    Rails.logger.info "sub to #{params[:id]}"
    User.pg_subscribe params[:id] do |ch, payload|
      Rails.logger.info "#{ch}: #{payload.inspect}"
      response.stream.write("event: #{ch}\n")
      response.stream.write("data: #{payload}\n\n")
    end

  rescue IOError
    logger.info "Stream closed"
  ensure
    response.stream.close
  end
end
