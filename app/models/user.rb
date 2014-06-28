class User < ActiveRecord::Base

  has_many :identities, class_name: "::UserIdentity", dependent: :nullify
  has_many :user_repos, through: :identities
  has_many :project_subscriptions, class_name: "::ProjectSubscription", dependent: :destroy
  has_many :active_project_subscriptions,
    ->{ where(subscribe: true).readonly }, class_name: "::ProjectSubscription"

  has_many :user_companies, dependent: :destroy
  has_many :companies, through: :user_companies

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  def update_role(role, company)
    user_company = user_companies.find_by(company: company)
    user_company.update(role: role)
  end

  def default_company(reload = false)
    if reload
      @default_company = nil
    end
    @default_company ||= companies.reorder("user_companies.default DESC").first
  end

  def role(company)
    if company
      user_companies.where(company: company).pluck(:role).first
    end
  end

  def admin?(company)
    role(company) == 'admin'
  end

  def developer?(company)
    role(company) == 'developer'
  end

  def sync_repos(company)
    transaction do
      active_identities.map do |identity|
        synced_repos = identity.sc.repos.map do |external_repo|
          UserRepo.find_or_create_by_sc company, identity, external_repo
        end
        identity.user_repos.where("id NOT IN (?)", synced_repos.map(&:id)).each do |user_repo|
          user_repo.destroy unless user_repo.project
        end
        synced_repos
      end
    end
  end

  def active_identities
    identities(true).to_a.select{|i| not i.ignored? }
  end

  def add_to_company(company, role = 'developer')
    user_company = user_companies.find_or_initialize_by(company_id: company.id)

    if user_company.persisted? and user_company.role == role
      return true
    end

    user_company.role = role
    if user_company.save
      user_company.default!
      user_company
    end
  end

  def delete_from_company(company)
    user_company = user_companies.find_by(company: company)

    if user_company
      transaction do
        user_repos.where(company: company).find_each do |user_repo|
          user_repo.unsubscribe
          user_repo.destroy
        end
        user_company.destroy
      end
    end
  end

  def update_with_company(company, params)
    transaction do
      if role = params.delete(:role)
        add_to_company(company, role).or_rollback_transaction
      end
      update(params).or_rollback_transaction
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
#  id          :integer          not null, primary key
#  email       :string(255)      not null
#  name        :string(255)      not null
#  created_at  :datetime
#  updated_at  :datetime
#  back_office :boolean          default(FALSE)
#

