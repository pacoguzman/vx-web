class ::Api::PullRequestsController < ::Api::BaseController

  respond_to :json

  def index
    respond_with(@builds = project.builds.with_pull_request.limit(20))
  end

  private

  def project
    @project ||= ::Project.find params[:project_id]
  end

end
