class UserCompany < ActiveRecord::Base
  ADMIN_ROLE = 'admin'
  DEVELOPER_ROLE = 'developer'

  before_validation :assign_default_role

  belongs_to :user
  belongs_to :company

  def self.roles
    [ADMIN_ROLE, DEVELOPER_ROLE]
  end

  validates :user, :company, :default, :role, presence: true
  validates :user_id, uniqueness: { scope: [:company_id] }
  validates :role, inclusion: { in: UserCompany.roles }

  def default?
    default == 1
  end

  def default!
    transaction do
      user.user_companies.where("id <> ?", id).update_all(default: 0)
      update default: 1
    end
  end

private

  def assign_default_role
    self.role ||= (company.users.any? ? DEVELOPER_ROLE : ADMIN_ROLE)
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

