class UserSession::GithubController < ApplicationController

  skip_before_filter :authorize_user

  def callback
    @do = o_params["do"]
    case @do
    when "sign_in"
      sign_in
    when "sign_up"
      sign_up
    end
  end

  private

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
      @company             = Company.find_by! name: o_params["company"]
      @github_user_session = UserSession::Github.new request.env["omniauth.auth"]
      @user                = @github_user_session.create_user(
        o_params["email"],
        @company
      )
      if @user
        session[:user_id] = @user.id
        redirect_to_saved_location_or_root
      else
        redirect_to '/auth/failure'
      end
    end

    def o_params
      request.env['omniauth.params']
    end

end
