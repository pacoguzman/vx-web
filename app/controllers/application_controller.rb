class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authorize_user

  helper_method :current_user,
                :user_logged_in?

  private

    def current_user
      @current_user ||=  User.first #::User.find_by id: session[:user_id].to_i
    end

    def user_logged_in?
      !!current_user
    end

    def authorize_user
      user_logged_in? || access_denied
    end

    def access_denied
      respond_to do |want|
        want.html { render 'welcome/login', layout: false }
        want.json { head 403 }
        want.all  { head 403 }
      end
      false
    end
end
