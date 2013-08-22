class JobLog < ActiveRecord::Base

  belongs_to :job

  validates :job_id, :tm, :tm_usec, presence: true

  default_scope ->{ order("job_logs.tm ASC, job_logs.tm_usec ASC") }

end
