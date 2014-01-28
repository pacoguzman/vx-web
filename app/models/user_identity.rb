class UserIdentity < ActiveRecord::Base

  belongs_to :user
  has_many :projects, dependent: :nullify, foreign_key: :identity_id,
    class_name: "::Project"
  has_many :user_repos, dependent: :destroy, foreign_key: :identity_id,
    class_name: "::UserRepo"

  validates :user_id, :provider, :uid, :token, presence: true
  validates :user_id, uniqueness: { scope: [:provider] }

  validates :url, presence: true, if: :gitlab?

  scope :provider, ->(provider) { where provider: provider }

  class << self
    # TODO: remove
    def find_by_provider(p)
      provider(p).first
    end

    def provider?(p)
      provider(p).exists?
    end
  end

  def github?
    provider.to_s == 'github'
  end

  def gitlab?
    provider.to_s == 'gitlab'
  end

  def service_connector
    @service_connector ||= begin
      connector_class = Vx::ServiceConnector.to(provider)
      case provider.to_sym
      when :github
        connector_class.new(login, token)
      end
    end
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

