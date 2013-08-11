class Api::BuildsController < Api::BaseController

  def index
    @builds = project.builds
    respond_to do |want|
      want.json { render json: @builds }
    end
  end

  def create
    @build = project.builds.build params[:build]
    respond_to do |want|
      if @build.save
        @build.publish_perform_build_message
        want.json { render json: @build }
      else
        want.json { render json: @build, status: :unprocessable_entity }
      end
    end
  end

  private

    def project
      @project ||= Project.find_by! name: params[:project_id]
    end

end
