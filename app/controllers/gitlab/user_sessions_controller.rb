module Gitlab
  class UserSessionsController < ApplicationController

    skip_before_filter :authorize_user
    layout false

    def create
      @gitlab_user_session = Gitlab::UserSession.new user_session_params
      if user = @gitlab_user_session.create
        session[:user_id] = user.id
        redirect_to root_path
      else
        render "welcome/signin", status: :unprocessable_entity
      end
    end

    private
      def user_session_params
        params.require(:gitlab_user_session).permit(:email, :password, :host)
      end

  end
end
