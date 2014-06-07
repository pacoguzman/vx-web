class Users::SignupController < ApplicationController

  skip_before_filter :authorize_user
  before_filter :build_omniauth, only: [:new, :create]

  layout "session"

  def show
  end

  def new
    @email        = params[:email] || @omniauth.info.email
    @company_name = params[:company] || @omniauth.info.nickname
  end

  def create
    @email        = params[:email]
    @company_name = params[:company]

    User.transaction do
      @company = Company.new(name: @company_name)
      @company.save.or_rollback_transaction

      github_session = UserSession::Github.new(@omniauth)
      @user = github_session.create_user(
        @email,
        @company
      )
    end

    if @user && @user.valid?
      session.delete(:signup_omniauth)
      session[:user_id] = @user.id
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
