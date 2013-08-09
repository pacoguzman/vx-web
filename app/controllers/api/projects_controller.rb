class Api::ProjectsController < Api::BaseController

  def index
    respond_to do |want|
      want.json { render json: Project.all }
    end
  end

  def show
    @project = Project.find_by_name params[:id]
    respond_to do |want|
      want.json { render json: @project }
    end
  end

end
