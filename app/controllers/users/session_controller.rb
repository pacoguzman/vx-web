class Users::SessionController < ApplicationController
  skip_before_filter :authorize_user, except: [:show]
  before_action :authorize_back_office_user, only: :become

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

  def show
    render layout: "theme"
  end

  def become
    user = User.find(params[:id])
    session[:user_id] = user.id
    redirect_to '/ui'
  end
end
