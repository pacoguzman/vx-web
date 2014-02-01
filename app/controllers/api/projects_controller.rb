class Api::ProjectsController < Api::BaseController

  respond_to :json

  def index
    @projects = Project.includes(user_repo: :identity)
    respond_with(@projects)
  end

  def show
    respond_with(@project = Project.find(params[:id]))
  end

end
