class Api::ProjectSubscriptionsController < Api::BaseController

  respond_to :json

  def create
    project.subscribe current_user
    respond_with(project, location: api_project_url(project))
  end

  def destroy
    project.unsubscribe current_user
    respond_with(project)
  end

  private
    def project
      @project ||= Project.find params[:project_id]
    end

end
