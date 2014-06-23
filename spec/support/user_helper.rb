module UserHelper
  def sign_in(user, company = nil)
    session[:user_id] = user.id
    user.add_to_company(company) if company
  end
end
