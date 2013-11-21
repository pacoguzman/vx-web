class ProjectSubscription < ActiveRecord::Base

  belongs_to :user
  belongs_to :project

  validates :project_id, :user_id, presence: true
  validates :user_id, uniqueness: { scope: :user_id }

end

