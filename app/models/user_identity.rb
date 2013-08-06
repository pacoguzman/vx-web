class UserIdentity < ActiveRecord::Base

  validates :user_id, :provider, :uid, :token, presence: true
  validates :user_id, uniqueness: { scope: [:provider] }

  belongs_to :user

  scope :provider, ->(provider) { where provider: provider }

  def self.find_by_provider(p)
    provider(p).first
  end

  def self.provider?(p)
    provider(p).exists?
  end

end
