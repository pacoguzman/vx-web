class UserCompany < ActiveRecord::Base
  ROLES = %w{
    admin
    developer
  }

  belongs_to :user
  belongs_to :company

  validates :user, :company, :default, :role, presence: true
  validates :user_id, uniqueness: { scope: [:company_id] }
  validates :role, inclusion: { in: ROLES }

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
#  default    :integer          default(0), not null
#  created_at :datetime
#  updated_at :datetime
#  role       :string(255)      not null
#  company_id :uuid             not null
#  user_id    :uuid             not null
#

