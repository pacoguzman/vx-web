class Api::JobLogsController < Api::BaseController

  respond_to :json

  def index
    respond_with(@job_logs = job.logs)
  end

  private

    def job
      @job ||= ::Job.find params[:job_id]
    end

end
