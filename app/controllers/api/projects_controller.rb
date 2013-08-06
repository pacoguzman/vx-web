class Api::ProjectsController < Api::BaseController
  respond_to :json

  def index
    respond_with(@projects = Project.all)
  end
end
