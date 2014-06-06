class User < ActiveRecord::Base

  has_many :identities, class_name: "::UserIdentity", dependent: :nullify
  has_many :user_repos, through: :identities
  has_many :project_subscriptions, class_name: "::ProjectSubscription", dependent: :destroy

  has_many :user_companies, dependent: :destroy
  has_many :companies, through: :user_companies

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  def default_company
    companies.order("user_companies.default").first
  end

  def sync_repos(company)
    transaction do
      identities.map do |identity|
        synced_repos = identity.sc.repos.map do |external_repo|
          UserRepo.find_or_create_by_sc company, identity, external_repo
        end
        UserRepo.where("id NOT IN (?)", synced_repos.map(&:id)).where(identity: identity).each do |user_repo|
          user_repo.destroy
        end
        synced_repos
      end
    end
  end

end

# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string(255)      not null
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

