class ::Api::BranchesController < ::Api::BaseController

  respond_to :json

  def index
    respond_with(@builds = project.builds_branch.limit(20))
  end

  private

  def project
    @project ||= ::Project.find params[:project_id]
  end

end
