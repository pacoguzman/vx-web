class ::Api::BuildsController < ::Api::BaseController

  respond_to :json
  skip_before_filter :authorize_user, only: [:status_for_gitlab]

  def index
    builds = project.builds.from_number(params[:from]).limit(30)
    respond_with(builds)
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

  def status_for_gitlab
    @token   = request.headers['HTTP_X_VEXOR_PROJECT_TOKEN']
    @sha     = params[:id]
    @project = Project.find_by! token: @token
    @status  = @project.status_for_gitlab(@sha)
    if @status
      render json: @status
    else
      render json: {}, status: :not_found
    end
  end

  private

    def project
      @project ||= current_company.projects.find params[:project_id]
    end

    def build
      @build ||= ::Build.find params[:id]
    end

end
