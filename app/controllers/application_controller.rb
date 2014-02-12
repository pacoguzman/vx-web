class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authorize_user

  helper_method :current_user,
                :user_logged_in?

  serialization_scope :current_user

  private

    def current_user
      @current_user ||= (
        development_user ||
        ::User.find_by(id: current_user_id.to_i)
      )
    end

    def current_user_id
      session[:user_id]
    end

    def development_user
      Rails.env.development? && User.first
    end

    def user_logged_in?
      !!current_user
    end

    def authorize_user
      user_logged_in? || access_denied
    end

    def access_denied
      save_location if request.format.html?

      respond_to do |want|
        want.html { render 'welcome/signin', layout: false, status: 403 }
        want.json { head 403 }
        want.all  { head 403 }
      end
      false
    end

    def redirect_to_saved_location_or_root
      redirect_to(session[:saved_location] || root_path)
      session[:saved_location] = nil
    end

    def save_location
      if request.fullpath != "/"
        session[:saved_location] ||= request.fullpath
      end
    end

end
