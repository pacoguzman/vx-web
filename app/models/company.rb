class Company < ActiveRecord::Base
  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :projects, dependent: :destroy
  has_many :user_repos, dependent: :destroy
  has_many :user_companies, dependent: :destroy
  has_many :users, through: :user_companies
  has_many :invites, dependent: :destroy
end
