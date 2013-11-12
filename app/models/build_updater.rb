class BuildUpdater

  attr_reader :message, :build

  def initialize(build_status_message)
    @message = build_status_message
  end

  def perform
    Build.transaction do
      @build = Build.lock(true).find_by(id: @message.build_id)
      if @build
        add_jobs_count_to_build
        update_build_status
        build.save!
        build.publish
        build.project.publish
      end
      @build
    end
  end

  private

    def update_build_status
      case message.status
      when 2 # started
        nil
      when 3 # finished
        nil  # ignored
      when 4 # failed
        build.decline
        build.finished_at = tm
      when 5 # errored
        build.error
        build.finished_at = tm
      end
    end

    def add_jobs_count_to_build
      build.jobs_count = message.jobs_count
    end

    def tm
      @tm ||= Time.at(message.tm)
    end
end
