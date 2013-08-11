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

# == Schema Information
#
# Table name: user_identities
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  provider   :string(255)      not null
#  token      :string(255)      not null
#  uid        :string(255)      not null
#  login      :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

