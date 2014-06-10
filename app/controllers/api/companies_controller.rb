class Api::CompaniesController < Api::BaseController

  def default
    company = Company.find params[:id]
    current_user.set_default_company company
    head :ok
  end

end
