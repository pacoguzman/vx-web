class JobUpdater

  attr_reader :message, :build

  def initialize(job_status_message)
    @message = job_status_message
    @build   = ::Build.find_by id: @message.build_id
  end

  def perform
    if build
      update_statuses
      build.save!
      build.project.pg_notify nil, build.to_json
    end
  end

  private

    def update_statuses

      case message.status
      when 2 # started
        build.start
        build.started_at = tm
        nil  # ignored
      when 3 # finished
        build.finish
        build.finished_at = tm
      when 4 # failed
        build.fail
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
