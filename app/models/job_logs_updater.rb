class JobLogsUpdater

  attr_reader :message, :build, :job

  def initialize(job_log_message)
    @message = job_log_message
    @job     = Job.find_by id: @message.job_id
  end

  def perform
    if job
      log = job.logs.append_log_message message
      log.publish :created
    end
  end
end
