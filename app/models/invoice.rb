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
      transition :waiting => :paid
    end

    event :decline do
      transition :waiting => :broken
    end

    event :cancel do
      transition any => :cancelled
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

