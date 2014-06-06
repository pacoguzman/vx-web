class Api::InvitesController < Api::BaseController
  before_action :authorize_admin

  respond_to :json

  def create
    invites = Invite.create(invite_params)
    invites.each(&:deliver)

    render json: :success
  end

private

  def invite_params
    emails = params.require(:invite)[:emails].try(:split, ' ')
    emails.map { |email| { email: email, company: current_company } }
  end
end
