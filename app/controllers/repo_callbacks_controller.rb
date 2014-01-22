class RepoCallbacksController < ApplicationController

  skip_before_filter :authorize_user
  skip_before_filter :verify_authenticity_token

  def create
    unless payload.ignore?
      Rails.logger.warn "ignore payload #{payload.inspect}"
      PayloadConsumer.publish payload
    end
    head :ok
  end

  private

    def payload
      @payload = Vx::ServiceConnector.payload(params[:_service], params)
    end

end
