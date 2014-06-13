class Api::InvitesController < Api::BaseController
  before_action :authorize_admin

  def create
    invites = Invite.mass_create(invite_params[:emails], current_company)
    if invites
      invites.each do |invite|
        UserMailer.invite(invite).deliver
      end
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

    def invite_params
      params.require(:invite).permit(:emails)
    end

end
