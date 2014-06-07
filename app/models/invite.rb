class Invite < ActiveRecord::Base
  validates :company_id, :email, :token, presence: true

  belongs_to :company

  before_validation :generate_token

  private

    def generate_token
      self.token ||= SecureRandom.uuid
    end
end

# == Schema Information
#
# Table name: invites
#
#  id         :integer          not null, primary key
#  company_id :integer          not null
#  token      :string(255)      not null
#  email      :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

