class Build < ActiveRecord::Base

  belongs_to :project

  validates :project_id, :number, :sha, :branch, presence: true
  validates :number, uniqueness: { scope: [:project_id] }


  before_validation :assign_number, on: :create
  before_validation :assign_sha,    on: :create
  before_validation :assign_branch, on: :create


  default_scope ->{ order 'builds.number DESC' }


  private

    def assign_number
      self.number = project.builds.maximum(:number).to_i + 1
    end

    def assign_sha
      self.sha ||= 'HEAD'
    end

    def assign_branch
      self.branch ||= 'master'
    end

end
