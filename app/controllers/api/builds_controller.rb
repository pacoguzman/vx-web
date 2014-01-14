class ::Api::BuildsController < ::Api::BaseController

  respond_to :json

  def index
    respond_with(@builds = project.builds.limit(20))
  end

  def show
    respond_with build
  end

  def restart
    if build.restart
      respond_with build, location: [:api, build]
    else
      head :unprocessable_entity
    end
  end

  private

    def project
      @project ||= ::Project.find params[:project_id]
    end

    def build
      @build ||= ::Build.find params[:id]
    end

end
