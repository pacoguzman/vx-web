class Api::ProjectsController < Api::BaseController

  def index
    respond_to do |want|
      want.json { render json: Project.all }
    end
  end

end
