class Invoice < ActiveRecord::Base
  belongs_to :company
  validates :amount, :company_id, presence: true

  default_scope ->{ order("invoices.created_at DESC") }
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

