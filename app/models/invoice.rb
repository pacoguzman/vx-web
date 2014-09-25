class Invoice < ActiveRecord::Base
  belongs_to :company
  validates :amount, :company_id, presence: true

  default_scope ->{ order("invoices.created_at DESC") }

  state_machine :status, initial: :pending do

    state :pending,   value: 0
    state :waiting,   value: 1
    state :paid,      value: 2
    state :broken,    value: 3
    state :cancelled, value: 4

    event :delivery do
      transition :pending => :waiting
    end

    event :pay do
      transition :pending => :paid
    end

    event :decline do
      transition :waiting => :broken
    end

    event :cancel do
      transition any => :cancelled
    end
  end

  def amount_string
    (amount.to_f / 100.0).to_s
  end

  def make_payment(nonce, customer_params)
    re = braintree_customer_create(nonce, customer_params)
    if re.success?
      re = braintree_transaction_sale(customer_params)
      if re.success?
        self.pay!
      else
        puts re.inspect
      end
    end
    re
  end

  private

    def braintree_transaction_sale(customer_params)
      Braintree::Transaction.sale(
        amount:      amount_string,
        customer_id: customer_params[:id]
      )
    end

    def braintree_customer_create(nonce, customer_params)
      begin
        params = customer_params.dup
        customer = Braintree::Customer.find(params[:id])
        customer_id = params.delete(:id)
        credit_card = {
          payment_method_nonce: nonce,
          options: {
            update_existing_token: customer.credit_cards[0].token
          }
        }
        Braintree::Customer.update(
          customer_id,
          params.merge(credit_card: credit_card)
        )
      rescue Braintree::NotFoundError
        Braintree::Customer.create(
          customer_params.merge(payment_method_nonce: nonce)
        )
      end
    end

end

# == Schema Information
#
# Table name: invoices
#
#  amount      :integer          not null
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  company_id  :uuid             not null
#  id          :uuid             not null, primary key
#  state       :integer          default(0), not null
#

