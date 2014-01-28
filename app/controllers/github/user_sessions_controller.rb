class Github::UserSessionsController < ApplicationController

  skip_before_filter :authorize_user

  def create
    @github_user_session = Github::UserSession.new env["omniauth.auth"]
    @user = @github_user_session.create
    if @user
      session[:user_id] = @user.id
      redirect_to root_path
    else
      redirect_to '/auth/failure'
    end
  end

end
