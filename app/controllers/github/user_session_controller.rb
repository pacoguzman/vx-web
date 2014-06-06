class Github::UserSessionController < ApplicationController

  skip_before_filter :authorize_user

  def sign_in
    @github_user_session = UserSession::Github.new request.env["omniauth.auth"]
    @user                = @github_user_session.find_user
    if @user
      session[:user_id] = @user.id
      redirect_to_saved_location_or_root
    else
      redirect_to '/auth/failure'
    end
  end

  def sign_up
    @company             = Company.find_by! name: params[:company]
    @github_user_session = UserSession::Github.new request.env["omniauth.auth"]
    @user                = @github_user_session.create_user(
      params[:email],
      @company
    )
    if @user
      session[:user_id] = @user.id
      redirect_to_saved_location_or_root
    else
      redirect_to '/auth/failure'
    end
  end

end
