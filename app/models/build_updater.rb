class BuildUpdater

  attr_reader :message, :build

  def initialize(build_status_message)
    @message = build_status_message
    @build   = Build.find_by id: @message.build_id
  end

  def perform
    if build
      add_commit_info_to_build
      add_jobs_info_to_build
      update_build_status

      build.save!
      build.publish
    end
  end

  private

    def update_build_status

      case message.status
      when 2 # started
        build.start
        build.started_at = tm
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

    def add_jobs_info_to_build
      build.assign_attributes jobs_count: message.jobs_count,
                              matrix:     message.matrix
    end

    def add_commit_info_to_build
      %w{ commit_sha commit_author commit_author_email
        commit_message }.inject({}) do |a, key|
        unless message.public_send(key).blank?
          a[key.to_sym] = message.public_send(key)
        end
        a
      end.tap do |h|
        build.sha          = h[:commit_sha]          if h[:commit_sha]
        build.author       = h[:commit_author]       if h[:commit_author]
        build.author_email = h[:commit_author_email] if h[:commit_author_email]
        build.message      = h[:commit_message]      if h[:commit_message]
      end
    end

    def tm
      @tm ||= Time.at(message.tm)
    end
end
