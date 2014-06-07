class Users::SignupController < ApplicationController

  skip_before_filter :authorize_user
  before_filter :build_omniauth, only: [:new, :create]

  layout "session"

  def show
  end

  def new
    @signup = UserSignup.new(
      @omniauth.info.nickname,
      @omniauth.info.email
    )
  end

  def create
    @signup = UserSignup.new(
      params[:company_name],
      params[:email],
      @omniauth
    )

    if @signup.create
      session.delete(:signup_omniauth)
      session[:user_id] = @signup.user.id
      redirect_to "/ui"
    else
      render :new
    end
  end

  private

    def build_omniauth
      @omniauth = session[:signup_omniauth]
      unless @omniauth.is_a?(OmniAuth::AuthHash)
        redirect_to users_signup_path
        false
      end
    end

end
