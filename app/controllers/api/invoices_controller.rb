class ::Api::InvoicesController < ::Api::BaseController

  respond_to :json

  def index
    invoices = current_company.invoices
    respond_with(invoices)
  end

end
