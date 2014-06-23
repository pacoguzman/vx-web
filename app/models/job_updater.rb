class JobUpdater

  attr_reader :message, :build, :job

  def initialize(job_status_message)
    @message = job_status_message
  end

  def project
    @project ||= Project.lock(true).find_by(id: message.project_id)
  end

  def build
    @build ||= project && project.builds.find_by(id: message.build_id)
  end

  def job
    @job ||= build && build.jobs.find_by(number: message.job_id)
  end

  def perform
    guard do
      update_and_save_job_status
      truncate_job_logs
      start_build?               and start_build
      all_regular_jobs_finished? and start_deploy
      all_jobs_finished?         and finalize_build
      true
    end
  end

  private

    def guard
      Build.transaction do
        if project && build && job
          begin
            yield
          # TODO: save and compare messages
          rescue AASM::InvalidTransition => e
            Vx::Instrumentation.handle_exception "job_updater.consumer.web.vx", e, message: message
            :invalid_transition
          end
        end
      end
    end

    def truncate_job_logs
      if message.status == 2
        JobLog.where(job_id: job.id).delete_all
        job.publish :logs_truncated
      end
    end

    def new_build_status
      if all_jobs_finished?
        maximum_status(build.jobs.where("status <> ?", 'cancelled')) # ignore cancelled jobs
      end
    end

    def all_jobs_finished?
      statuses = ["passed", "failed", "errored", "cancelled"]
      build.jobs.where(status: statuses).count == build.jobs.count
    end

    def all_regular_jobs_finished?
      statuses = ["passed", "failed", "errored"]
      build.jobs.regular.where(status: statuses).count == build.jobs.regular.count
    end

    def start_deploy
      return true if build.deploying?
      return true if build.jobs.deploy.empty?

      status = maximum_status(build.jobs.regular)

      if status == :passed or status == nil # passed
        build.deploy!
        build.publish_perform_deploy_job_messages
      else
        build.jobs.deploy.map(&:cancel!)
      end

      true
    end

    def start_build?
      message.status == 2 && build.status_name == :initialized
    end

    def update_and_save_job_status
      case message.status
      when 0 # initialized
        nil
      when 2 # started
        job.started_at = tm
        job.start!
      when 3 # finished
        job.finished_at = tm
        job.pass!
      when 4 # failed
        job.finished_at = tm
        job.decline!
      when 5 # errored
        job.finished_at = tm
        job.error!
      end
    end

    def start_build
      build.started_at = tm
      build.start!
    end

    def finalize_build
      case new_build_status.to_s
      when "passed"
        build.finished_at = tm
        build.pass!
      when "failed"
        build.finished_at = tm
        build.decline!
      when "errored"
        build.finished_at = tm
        build.error!
      end
    end

    def tm
      @tm ||= Time.at(message.tm)
    end

    def maximum_status(relation)
      # relation.maximum(:status) # we haven't integers anymore

      existing = relation.pluck(:status).map(&:to_sym).uniq
      build.aasm.states.select { |state| existing.include?(state.name) }.max_by { |state| state.options[:value] }.try(:name)
    end

end
