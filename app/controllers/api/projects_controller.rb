class Api::ProjectsController < Api::BaseController

  respond_to :json

  def index
    respond_with(@projects = Project.all)
  end

  def show
    respond_with(@project = Project.find(params[:id]))
  end

end
