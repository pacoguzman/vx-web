class Invite < ActiveRecord::Base
  belongs_to :company

  before_validation :generate_token

  validates :company, :email, :token, presence: true

  class << self
    def mass_create(emails, company)
      list = emails.to_s.split(" ")
      transaction do
        list.map do |email|
          invite = create(company: company, email: email)
          invite.persisted?.or_rollback_transaction
          invite
        end
      end
    end
  end

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

