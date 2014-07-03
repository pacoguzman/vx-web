BuildNotifier = Struct.new(:message) do

  def build
    @build ||= begin
      b = ::Build.new message
      b.freeze
      b
    end
  end

  def project
    build && build.project
  end

  def notify
    if build
      create_commit_status
      delivery_email_notifications
      true
    end
  end

  def delivery_email_notifications
    if build.notify?
      project_subscriptions.each do |sub|
        ::BuildsMailer.status_email(build, sub).deliver
      end
    end
  end

  def project_subscriptions
    project.subscriptions.active.joins(:user)
  end

  def description
    if build
      tm = build.duration.to_i
      duration = tm > 0 ? " in #{tm}s" : ""
      n  = build.number
      case build.status_name
      when :started
        "Vexor CI: build ##{n} started and still running"
      when :passed
        "Vexor CI: build ##{n} is successfully completed#{duration}"
      when :failed
        "Vexor CI: build ##{n} failed#{duration}"
      when :errored
        "Vexor CI: build ##{n} broken#{duration}"
      end
    end
  end

  private

    def create_commit_status
      sc  = project.sc
      if sc
        begin
          sc.notices(project.sc_model).create(
            build.sha,
            build.status_name,
            build.public_url,
            description
          )
        rescue Exception => exception
          Vx::Instrumentation.handle_exception(
            'consumer.web.vx',
            exception,
            build.attributes
          )
        end
      end
    end

end
