module Gitlab
  class UserSessionsController < ApplicationController

    skip_before_filter :authorize_user
    layout false

    def create
      @gitlab_user_session = Gitlab::UserSession.new user_session_params
      if @gitlab_user_session.create
        redirect_to root_path
      else
        render "welcome/signin"
      end
    end

    private
      def user_session_params
        params.require(:gitlab_user_session).permit(:email, :password, :host)
      end

  end
end
