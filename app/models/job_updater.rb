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

        update_job_status
        publish_job

        if all_jobs_finished? || build_need_start?
          start_build
          finalize_build
          build.save!
          publish_build_and_project
        end
      end
    end
  end

  def new_build_status
    build.jobs.maximum(:status)
  end

  def all_jobs_finished?
    statuses = [3,4,5]
    build.jobs.where(status: statuses).count == build.jobs_count
  end

  def build_need_start?
    message.status == 2 && build.status_name == :initialized
  end

  private

    def publish_job
      if message.status == 0
        job.publish :created
      else
        job.publish
      end
    end

    def update_job_status
      case message.status
      when 0 # initialized
        nil
      when 2 # started
        job.start
        job.started_at  = tm
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
      job.save!
    end

    def start_build
      build.start
      build.started_at = tm
    end

    def finalize_build
      case new_build_status
      when 3
        build.finish
        build.finished_at = tm
      when 4
        build.decline
        build.finished_at = tm
      when 5
        build.error
        build.finished_at = tm
      end
    end

    def publish_build_and_project
      build.publish serializer: :build_status
      build.project.publish
    end

    def tm
      @tm ||= Time.at(message.tm)
    end

end
