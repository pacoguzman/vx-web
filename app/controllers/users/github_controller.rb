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
      company = Company.find_by! name: company_name
      invite  = company.invites.find_by! token: token, email: email
      github  = UserSession::Github.new request.env["omniauth.auth"]
      user    = github.create(email, trust_email: true)

      if user.valid?
        # TODO: check add_to_company result
        user.add_to_company company
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

    def email
      o_params["email"]
    end

    def token
      o_params["token"]
    end

    def company_name
      o_params["company"]
    end

end
