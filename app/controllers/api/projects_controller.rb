class ::Api::ProjectsController < ::Api::BaseController

  respond_to :json
  skip_before_filter :authorize_user, only: [:key]

  def index
    @projects = current_company.projects.includes([:user, :identity])
    respond_with(@projects, serializer: ProjectsSerializer)
  end

  def show
    respond_with(project)
  end

  def key
    @project = Project.find params[:id]
    respond_to do |want|
      want.txt {
        render text: @project.public_deploy_key, content_type: "text/plain"
      }
    end
  end

  private
    def project
      @project ||= current_company.projects.find params[:id]
    end

end
