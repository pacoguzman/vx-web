class UserSession::SessionController < ApplicationController

  skip_before_filter :authorize_user, except: [:show]

  def destroy
    session.delete(:user_id)
    respond_to do |want|
      want.json {
        render json: { location: "/ui" }
      }
      want.html {
        redirect_to "/ui"
      }
    end
  end

  def sign_up
    @email   = params[:email]
    @company = Company.find_by! name: params[:company]
    @invite  = @company.invites.find_by! token: params[:token], email: @email

    render layout: "session"
  end

  def show
    render layout: "application"
  end
end
