class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    raise request.env["omniauth.auth"].inspect
  end
end
