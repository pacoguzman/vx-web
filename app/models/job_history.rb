class JobHistory < ActiveRecord::Base
  belongs_to :company

  default_scope ->{ order("job_histories.created_at") }

  validates :duration, :company, :build_number, :job_number, presence: true
end
