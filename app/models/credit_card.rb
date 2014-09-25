CreditCard = Struct.new(:company) do

  Card = Struct.new(:owner, :token, :number, :type, :image_url) do
    def as_json(*args)
      {
        token:        !!token,
        number:       number,
        type:         type,
        image_url:    image_url,
        client_token: braintree_client_token
      }
    end

    def braintree_client_token
      if owner.enabled?
        Braintree::ClientToken.generate()
      end
    end
  end

  def find
    card = nil
    begin
      if enabled?
        customer = Braintree::Customer.find(company.id)
        existing_card = customer.credit_cards[0]
        if existing_card
          card = Card.new(
            self,
            existing_card.token,
            "**** **** **** #{existing_card.last_4}",
            existing_card.card_type,
            existing_card.image_url,
          )
        end
      end
    rescue Braintree::NotFoundError
      nil
    end
    card || card_not_found
  end

  def enabled?
    Rails.configuration.x.braintree
  end

  def create(nonce, email)
    begin
      customer = Braintree::Customer.find(company.id)
      params = {
        email:      email,
        company:    company.name,
        first_name: company.name,
        credit_card: {
          payment_method_nonce: nonce,
          options: {
            update_existing_token: customer.credit_cards[0].token
          }
        }
      }
      Braintree::Customer.update( company.id, params )
    rescue Braintree::NotFoundError
      Braintree::Customer.create(
        id:         company.id,
        email:      email,
        company:    company.name,
        first_name: company.name,
        payment_method_nonce: nonce
      )
    end
  end

  private

    def card_not_found
      Card.new(self, nil, nil, nil, nil)
    end

end
