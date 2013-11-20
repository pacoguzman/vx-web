class BuildsMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  default from: "from@example.com"

  def status_email(build, recipients)
    @build = build
    @project = build.project
    mail(to: recipients, subject: build_subject(build))
  end

  def build_subject(build)
    "[#{build.status_name.capitalize}] #{build.project}##{build.number} (#{build.branch} - #{build.short_sha})"
  end

end
