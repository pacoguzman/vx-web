class Api::BuildsController < Api::BaseController

  respond_to :json

  def index
    respond_with(@builds = project.builds.limit(30))
  end

  def create
    @build = project.builds.build params[:build]
    if @build.save
      @build.publish :created
      @build.publish_perform_build_message
    end
    respond_with @build, location: [:api, @build]
  end

  def show
    @build = Build.find params[:id]
    respond_with @build
  end

  private

    def project
      @project ||= ::Project.find params[:project_id]
    end

end
