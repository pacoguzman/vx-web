class JobLog < ActiveRecord::Base

  extend AppendLogMessage

  belongs_to :job

  validates :job_id, :tm, :tm_usec, presence: true

  default_scope ->{ order("job_logs.tm ASC, job_logs.tm_usec ASC") }

  def log_id
    [job_id, tm, tm_usec].join('.')
  end

end
