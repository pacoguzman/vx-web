class BuildNotifier
  include ::Github::BuildNotifier

  attr_reader :message

  def initialize(message)
    @message  = message
  end

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
      create_github_commit_status
      delivery_email_notifications
    end
  end

  def delivery_email_notifications
    if subscribed_emails.any? && build.notify?
      ::BuildsMailer.status_email(build, subscribed_emails).deliver
    end
  end

  def subscribed_emails
    project.subscriptions
           .active
           .joins(:user)
           .select("users.email AS user_email")
           .map(&:user_email)
  end

  def description
    if build
      n  = build.number
      case build.status_name
      when :started
        "EvroneCI build ##{n} started"
      when :passed
        "EvroneCI build ##{n} successed"
      when :failed
        "EvroneCI build ##{n} failed"
      when :errored
        "EvroneCI build ##{n} broken"
      end
    end
  end

  private

    def identity_not_found
      raise RuntimeError, "identity on project ID=#{build.project_id} is not exists"
    end
end
