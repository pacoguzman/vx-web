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
      lines = data.split(/(?<=\n)/) # keep new line
      last_log = job.logs.last

      if last_log && last_log.data.index("\n").nil?
        first_line = lines.shift
        last_log.update_attribute :data, "#{last_log.data}#{first_line}"
        last_log.publish :updated
      end

      lines.each do |line|
        log = job.logs.create! tm: tm, tm_usec: tm_usec, data: line
        log.publish :created
      end
    end
  end

  private

    def tm
      message.tm
    end

    def tm_usec
      message.tm_usec
    end

    def data
      message.log
    end

end
