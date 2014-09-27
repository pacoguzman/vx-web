class Api::CreditCardsController < Api::BaseController
  before_filter :authorize_admin
  before_filter :validate_card_params, only: [:create]

  def show
    render json: find_card.to_json
  end

  def create
    re = current_company.credit_card.create(params[:nonce], current_user.email)
    if re.success?
      render json: find_card.to_json
    else
      render json: {
        errors: re.errors.map(&:message)
      }, status: :unprocessable_entity
    end
  end

  private

    def find_card
      current_company.credit_card.find
    end

    def validate_card_params
      if params[:nonce].blank? || !Rails.configuration.x.braintree
        head :bad_request
      end
    end

end
