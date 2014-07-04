class Invoice < ActiveRecord::Base
  belongs_to :company
end

# == Schema Information
#
# Table name: invoices
#
#  id          :integer          not null, primary key
#  amount      :decimal(, )      not null
#  state       :string(255)      not null
#  description :string(255)
#  started_at  :datetime         not null
#  finished_at :datetime         not null
#  created_at  :datetime
#  updated_at  :datetime
#  company_id  :uuid
#

