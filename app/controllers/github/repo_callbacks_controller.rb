class Github::RepoCallbacksController < ApplicationController

  skip_before_filter :authorize_user
  skip_before_filter :verify_authenticity_token

  def create
    PayloadConsumer.publish params
=begin
    @project = Project.find_by_token params[:token]
    @payload = Github::Payload.new(params)

    if @payload.ignore?
      Rails.logger.info "ignore pull request"
    else
      @build  = @project.create_build_from_github_payload(@payload)
      @build.delivery_to_fetcher
    end
=end

    head :ok
  end

end
