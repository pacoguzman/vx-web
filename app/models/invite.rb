class Invite < ActiveRecord::Base
  validates :company_id, :email, :token, presence: true

  before_validation :generate_token

  private

    def generate_token
      self.token ||= SecureRandom.uuid
    end
end
