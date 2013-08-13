class BuildUpdater

  attr_reader :message, :build

  def initialize(build_status_message)
    @message = build_status_message
    @build   = ::Build.find_by id: @message.build_id
  end

  def perform
    if build
      update_status
      build.save!
      build.project.publish
    end
  end

  private

    def update_status

      case message.status
      when 2 # started
        build.in_queue
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

    def tm
      @tm ||= Time.at(message.tm)
    end
end
