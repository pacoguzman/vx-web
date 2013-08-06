class Project < ActiveRecord::Base

  validates :name, :url, :provider, presence: true
  validates :provider, inclusion: { in: %w{ github } }

end
