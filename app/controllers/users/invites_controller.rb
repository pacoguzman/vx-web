class Users::InvitesController < ApplicationController

  skip_before_filter :authorize_user

  def new
    @email   = params[:email]
    @company = Company.find params[:company]
    @invite  = @company.invites.find_by! token: params[:token], email: @email

    render layout: "session"
  end

end
