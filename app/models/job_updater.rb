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
      update_job_status
      publish_job

      if update_build?
        update_build_status
        publish_build_and_project
      end
    end
  end

  def update_build?
    statuses = [3,4,5]
    build.jobs.where(status: statuses).count == build.jobs_count
  end

  def new_build_status
    build.jobs.maximum(:status)
  end

  private

    def publish_job
      if message.status == 2
        job.publish :created
      else
        job.publish
      end
    end

    def update_job_status
      case message.status
      when 2 # started
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
      job.save!
    end

    def update_build_status
      case new_build_status
      when 3
        build.finish
      when 4
        build.decline
      when 5
        build.error
      end
      build.finished_at = tm
      build.save!
    end

    def publish_build_and_project
      build.publish serializer: :build_status
      build.project.publish
    end

    def tm
      @tm ||= Time.at(message.tm)
    end

end
