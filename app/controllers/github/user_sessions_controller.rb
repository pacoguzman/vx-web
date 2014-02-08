class Github::UserSessionsController < ApplicationController

  skip_before_filter :authorize_user

  def create
    github_user_session = Github::UserSession.new request.env["omniauth.auth"]
    user = github_user_session.create
    if user
      session[:user_id] = user.id
      redirect_to_saved_location_or_root
    else
      redirect_to '/auth/failure'
    end
  end

end
