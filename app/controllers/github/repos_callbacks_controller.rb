class Github::ReposCallbacksController < Api::BaseController

  skip_before_filter :authorize_user
  skip_before_filter :intercept_html_requests

  def create
    @project = ::Project.find_by_token params[:token]
    @payload = ::Github::Payload.new(params)
    @project.create_build_from_github_payload(@payload)
    head :ok
  end

end
