class User < ActiveRecord::Base

  has_many :identities, class_name: "::UserIdentity", dependent: :nullify
  has_many :user_repos, through: :identities
  has_many :project_subscriptions, class_name: "::ProjectSubscription", dependent: :destroy

  has_many :user_companies, dependent: :destroy
  has_many :companies, through: :user_companies

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  def default_company
    companies.reorder("user_companies.default DESC").first
  end

  def sync_repos(company)
    transaction do
      active_identities.map do |identity|
        synced_repos = identity.sc.repos.map do |external_repo|
          UserRepo.find_or_create_by_sc company, identity, external_repo
        end
        identity.user_repos.where("id NOT IN (?)", synced_repos.map(&:id)).each do |user_repo|
          user_repo.destroy
        end
        synced_repos
      end
    end
  end

  def active_identities
    identities(true).to_a.select{|i| not i.ignored? }
  end

  def add_to_company(company)
    user_company = user_companies.find_or_initialize_by(
      company_id: company.id
    )
    if user_company.save
      user_company.default!
      user_company
    end
  end

  def set_default_company(company)
    user_companies.where(company_id: company.id).map(&:default!)
    touch
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

