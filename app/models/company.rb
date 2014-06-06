class Company < ActiveRecord::Base
  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :projects, dependent: :destroy
  has_many :user_repos, dependent: :destroy
end
