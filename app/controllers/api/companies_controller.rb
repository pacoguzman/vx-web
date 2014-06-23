class Api::CompaniesController < Api::BaseController
  before_filter :authorize_admin, only: :usage

  respond_to :json

  def default
    company = Company.find params[:id]
    current_user.set_default_company company
    head :ok
  end

  def usage
    company_usage = CompanyUsage.new(current_company)
    respond_with(company_usage.to_json)
  end
end
