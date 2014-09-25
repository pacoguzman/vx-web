class ::Api::InvoicesController < ::Api::BaseController

  before_filter :validate_payment_params, only: [:pay]

  respond_to :json

  def index
    invoices = current_company.invoices
    respond_with(invoices)
  end

  def pay
    result = Braintree::Transaction.sale(
      amount: invoice.amount_string,
      order_id: invoice.id,
      payment_method_nonce: params[:nonce],
      customer: {
        company: current_company.name,
        email: current_user.email,
      }
    )
    if result.success?
      invoice.pay!
      respond_with(invoice, location: '')
    else
      render json: {
        errors: result.errors.map(&:message)
      }, status: :unprocessable_entity
    end
  end

  private

    def invoice
      @invoice ||= current_company.invoices.find params[:id]
    end

    def validate_payment_params
      if params[:nonce].blank? || !Rails.configuration.x.braintree
        head :bad_request
      end
    end

end
