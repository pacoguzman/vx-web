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

end
