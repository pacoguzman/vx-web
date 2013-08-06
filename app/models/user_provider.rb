class UserProvider < ActiveRecord::Base
  validates :user_id, :provider, :uid, presence: true

  belongs_to :user
end
