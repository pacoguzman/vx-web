class Api::ProjectsController < Api::BaseController

  respond_to :json

  def create
  end

  def destroy
  end

  private
    def project
      @project ||= Project.find params[:id]
    end

end
