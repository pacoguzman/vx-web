class Invoice < ActiveRecord::Base
  include AASM

  belongs_to :company
  validates :amount, :company_id, presence: true

  default_scope ->{ order("invoices.created_at DESC") }

  aasm column: :status do
    state :pending,   value: 0, initial: true
    state :waiting,   value: 1
    state :paid,      value: 2
    state :broken,    value: 3
    state :cancelled, value: 4

    event :delivery do
      transitions from: :pending, to: :waiting
    end

    event :pay do
      transitions from: :pending, to: :paid
    end

    event :decline do
      transitions from: :waiting, to: :broken
    end

    event :cancel do
      # :any => :cancelled
      transitions from: [:pending, :waiting, :paid, :broken, :cancelled], to: :cancelled
    end
  end

  def status_name
    status.to_sym
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

