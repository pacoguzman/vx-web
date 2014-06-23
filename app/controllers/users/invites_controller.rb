class Users::InvitesController < ApplicationController

  skip_before_filter :authorize_user

  def new
    @invite  = Invite.find_by! id: params[:i], token: params[:t]

    render layout: "session"
  end

end
