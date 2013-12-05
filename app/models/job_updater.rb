class JobUpdater

  attr_reader :message, :build, :job

  def initialize(job_status_message)
    @message = job_status_message
  end

  def perform
    Job.transaction do
      @build = Build.lock(true).find_by(id: message.build_id)
      if build
        @job = build.find_or_create_job_by_status_message(message)

        update_and_save_job_status!
        truncate_job_logs

        if build_need_start?
          start_build!
        end

        if all_jobs_finished?
          finalize_build!
        end
      end
    end
  end

  private

    def truncate_job_logs
      if message.status == 2
        JobLog.where(job_id: job.id).delete_all
      end
    end

    def new_build_status
      if all_jobs_finished?
        build.jobs.maximum(:status)
      end
    end

    def all_jobs_finished?
      statuses = [3,4,5]
      build.jobs.where(status: statuses).count == build.jobs_count
    end

    def build_need_start?
      message.status == 2 && build.status_name == :initialized
    end

    def update_and_save_job_status!
      case message.status
      when 0 # initialized
        nil
      when 2 # started
        job.started_at  = tm
        job.start!
      when 3 # finished
        job.finished_at = tm
        job.pass! unless job.passed?
      when 4 # failed
        job.finished_at = tm
        job.decline!
      when 5 # errored
        job.finished_at = tm
        job.error!
      end
    end

    def start_build!
      if build_need_start?
        build.started_at = tm
        build.start!
      end
    end

    def finalize_build!
      case new_build_status
      when 3
        build.finished_at = tm
        build.pass!
      when 4
        build.finished_at = tm
        build.decline!
      when 5
        build.finished_at = tm
        build.error!
      end
    end

    def tm
      @tm ||= Time.at(message.tm)
    end

end
