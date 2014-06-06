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
      update_attribute :default, 1
    end
  end
end
