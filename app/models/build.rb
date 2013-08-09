class Build < ActiveRecord::Base

  belongs_to :project

  validates :project_id, :number, :ref, :branch, presence: true
  validates :number, uniqueness: { scope: [:project_id] }


  before_validation :assign_number, on: :create
  before_validation :assign_ref,    on: :create
  before_validation :assign_branch, on: :create


  private

    def assign_number
      self.number = project.builds.maximum(:number).to_i + 1
    end

    def assign_ref
      self.ref ||= 'HEAD'
    end

    def assign_branch
      self.branch ||= 'master'
    end

end
