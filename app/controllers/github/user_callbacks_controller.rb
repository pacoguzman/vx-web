class Github::UserCallbacksController < ApplicationController

  skip_before_filter :authorize_user

  def create
    user = User.from_github env['omniauth.auth']
    if user
      session[:user_id] = user.id
      redirect_to root_path
    else
      redirect_to '/auth/failure'
    end
  end

end
