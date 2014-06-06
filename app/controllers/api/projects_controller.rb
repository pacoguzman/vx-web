class Api::ProjectsController < Api::BaseController

  respond_to :json
  skip_before_filter :authorize_user, only: [:key]

  def index
    @projects = current_companny.projects.includes(user_repo: :identity)
    respond_with(@projects)
  end

  def show
    respond_with(project)
  end

  def key
    render text: project.public_deploy_key, content_type: "text/plain"
  end

  private
    def project
      @project ||= current_company.projects.find params[:id]
    end

end
