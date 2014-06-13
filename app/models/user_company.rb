class UserCompany < ActiveRecord::Base
  validates :user_id, :company_id, :default, presence: true
  validates :user_id, uniqueness: { scope: [:company_id] }

  belongs_to :user
  belongs_to :company

  def default?
    default == 1
  end

  def default!
    transaction do
      user.user_companies.where("id <> ?", id).update_all(default: 0)
      update default: 1
    end
  end
end

# == Schema Information
#
# Table name: user_companies
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  company_id :integer          not null
#  default    :integer          default(0), not null
#  created_at :datetime
#  updated_at :datetime
#

