class BuildsMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  default from: "\"Vexor CI\" <no-reply@#{Rails.configuration.x.hostname.host}>"

  def status_email(build, subscription)
    @subscription = subscription
    @user         = subscription.user
    @build        = build
    @project      = build.project
    mail(to: @user.email, subject: build_subject(build))
  end

  def build_subject(build)
    "[#{build.human_status_name}] #{build.project}##{build.number} (#{build.branch} - #{build.short_sha})"
  end

end
