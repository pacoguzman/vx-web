class UserIdentity < ActiveRecord::Base

  belongs_to :user
  has_many :user_repos, dependent: :destroy, foreign_key: :identity_id,
    class_name: "::UserRepo"

  validates :user_id, :provider, :uid, :token, :url, presence: true
  validates :user_id, uniqueness: { scope: [:provider, :url] }
  validates :provider, inclusion: { in: ["github", "gitlab"] }

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

  def sc
    @sc ||= begin
      if ignored?
        raise RuntimeError, "provider #{provider.inspect} with version #{version.inspect} ignored"
      end

      sc_class = Vx::ServiceConnector.to(real_provider_name)
      case provider.to_s
      when "github"
        sc_class.new(login, token)
      when "gitlab"
        sc_class.new(url, token)
      end
    end
  end

  def unsubscribe_projects
    user_repos.map(&:unsubscribe_project)
  end

  def unsubscribe_and_destroy
    transaction do
      unsubscribe_projects
      destroy
    end
  end

  def ignored?
    not real_provider_name
  end

  def major_version
    version.to_s.split(".", 2).first
  end

  private

    def real_provider_name
      case provider.to_s
      when "github"
        "github"
      when "gitlab"
        if major_version
          "gitlab_v#{major_version}"
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
#  url        :string(255)      not null
#  version    :string(255)
#

