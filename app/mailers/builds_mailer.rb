class BuildsMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  layout 'mailer'

  default from: "\"Vexor CI\" <no-reply@#{Rails.configuration.x.hostname.host}>"

  def status_email(build, subscription)
    @subscription = subscription
    @user         = subscription.user
    @build        = build
    @project      = build.project
    @json_ld      = json_ld(build)
    mail(to: @user.email, subject: build_subject(build))
  end

  def build_subject(build)
    "[#{build.human_status_name}] #{build.project}##{build.number} (#{build.branch} - #{build.short_sha})"
  end

  private

  def json_ld(build)
    {
      "@context" => "http://schema.org",
      "@type" => "EmailMessage",
      "action" => {
        "@type" => "ViewAction",
        "url" => build.public_url,
        "name" => "View build"
      },
      "description" => "View the '#{build.project}' build online"
    }
  end

end
