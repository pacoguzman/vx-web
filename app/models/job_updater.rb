class JobUpdater

  attr_reader :message, :build, :job

  def initialize(job_status_message)
    @message = job_status_message
    @build   = ::Build.find_by id: @message.build_id
    if @build
      @job = Job.find_or_create_by_status_message(job_status_message)
    end
  end

  def perform
    if build
      update_statuses
      build.save!
      build.publish

      update_job_status
      job.save!
      job.publish
    end
  end

  private

    def update_job_status

      case message.status
      when 2 # started
        job.publish :created
        job.start
        job.started_at = tm
      when 3 # finished
        job.finish
        job.finished_at = tm
      when 4 # failed
        job.decline
        job.finished_at = tm
      when 5 # errored
        job.error
        job.finished_at = tm
      end

    end

    def update_statuses

      case message.status
      when 2 # started
        nil  # ignored
      when 3 # finished
        build.finish
        build.finished_at = tm
      when 4 # failed
        build.decline
        build.finished_at = tm
      when 5 # errored
        build.error
        build.finished_at = tm
      end

    end

    def tm
      @tm ||= Time.at(message.tm)
    end

end
