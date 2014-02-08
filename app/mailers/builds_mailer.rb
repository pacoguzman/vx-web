class BuildsMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  default from: "\"Vexor CI\" <no-reply@#{Rails.configuration.x.hostname}>"

  def status_email(build, recipients)
    @build   = build
    @project = build.project
    mail(to: recipients, subject: build_subject(build))
  end

  def build_subject(build)
    "[#{build.human_status_name}] #{build.project}##{build.number} (#{build.branch} - #{build.short_sha})"
  end

end
