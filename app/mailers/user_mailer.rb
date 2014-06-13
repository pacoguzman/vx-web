class UserMailer < ActionMailer::Base
  default from: "\"Vexor CI\" <no-reply@#{ Rails.configuration.x.hostname.host }>"

  def invite(invite)
    @invite = invite
    mail(to: @invite.email, subject: 'Invitation to Vexor CI')
  end
end
