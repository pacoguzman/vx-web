class Users::GithubController < ApplicationController

  skip_before_filter :authorize_user

  def callback
    @do = o_params["do"]
    case @do
    when "sign_in"
      sign_in
    when "sign_up"
      sign_up
    when "invite"
      invite
    end
  end

  private

    def sign_up
      omniauth = request.env["omniauth.auth"]
      session[:signup_omniauth] = omniauth.except('extra')
      redirect_to new_users_signup_path
    end

    def sign_in
      github = UserSession::Github.new request.env["omniauth.auth"]
      user   = github.find
      if user
        session[:user_id] = user.id
        redirect_to_saved_location_or_root
      else
        redirect_to '/users/failure'
      end
    end

    def invite
      invite  = Invite.find_by! token: token, id: invite_id
      company = invite.company
      email   = invite.email
      github  = UserSession::Github.new request.env["omniauth.auth"]
      user    = github.create(email, trust_email: true)

      if user.valid? and user.add_to_company(company, role: invite.role)
        invite.destroy
        session[:user_id] = user.id
        redirect_to_saved_location_or_root
      else
        redirect_to '/users/failure'
      end
    end

    def o_params
      request.env['omniauth.params']
    end

    def token
      o_params["t"]
    end

    def invite_id
      o_params["i"]
    end

end
