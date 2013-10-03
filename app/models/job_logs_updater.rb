class JobLogsUpdater

  attr_reader :message, :build, :job

  def initialize(job_log_message)
    @message = job_log_message
    @build   = ::Build.find_by id: @message.build_id

    if @build
      @job = @build.jobs.find_by number: @message.job_id
    end
  end

  def perform
    if job
      created, updated = job.logs.append_log_message message

      created.each {|l| l.publish :created }
      updated.each {|l| l.publish :updated }
    end
  end
end
