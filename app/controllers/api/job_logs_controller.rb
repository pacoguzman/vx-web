class Api::JobLogsController < Api::BaseController

  def index
    @job_logs = job.logs

    respond_to do |want|
      want.json { render json: @job_logs }
      want.txt  { render text: @job_logs.map(&:data).join("\n") }
    end
  end

  private

    def job
      @job ||= ::Job.find params[:job_id]
    end

end
