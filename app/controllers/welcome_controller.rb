class WelcomeController < ApplicationController

  skip_before_filter :authorize_user, except: [:show]

  def invite
    @email   = params[:email]
    @company = Company.find_by! name: params[:company]
    @invite  = @company.invites.find_by! token: params[:token], email: @email

    render layout: "session"
  end

  def show
    render layout: "application"
  end
end
