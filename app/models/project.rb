class Project < ActiveRecord::Base

  validates :name, :http_url, :clone_url, :provider, presence: true
  validates :provider, inclusion: { in: %w{ github } }
  validates :name, uniqueness: true

  scope :github, -> { where provider: :github }

end
