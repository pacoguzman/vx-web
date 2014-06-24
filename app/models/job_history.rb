class JobHistory < ActiveRecord::Base
  belongs_to :company

  default_scope order('created_at DESC')

  validates :duration, :company, :build_number, :job_number, presence: true
end
