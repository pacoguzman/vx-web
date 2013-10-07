class Github::RepoCallbacksController < ApplicationController

  skip_before_filter :authorize_user
  skip_before_filter :verify_authenticity_token

  def create
    @project = Project.find_by_token params[:token]
    @payload = Github::Payload.new(params)
    @build   = @project.create_build_from_github_payload(@payload)

    @build.publish :created
    @build.delivery_to_fetcher

    head :ok
  end

end
