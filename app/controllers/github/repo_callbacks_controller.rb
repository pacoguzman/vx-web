class Github::RepoCallbacksController < ApplicationController

  skip_before_filter :authorize_user
  skip_before_filter :verify_authenticity_token

  def create
    PayloadConsumer.publish params
    head :ok
  end

end
