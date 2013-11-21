class Api::JobsController < ::Api::BaseController

  respond_to :json

  def index
    respond_with(@jobs = build.jobs)
  end

  def show
    @job = Job.find params[:id]
    respond_with @job
  end

  private

    def build
      @build ||= ::Build.find params[:build_id]
    end

end
