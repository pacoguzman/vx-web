class JobLog < ActiveRecord::Base

  belongs_to :job

  validates :job_id, :tm, :tm_usec, presence: true

  default_scope ->{ order("job_logs.tm ASC, job_logs.tm_usec ASC") }

  def id
    [job_id, tm, tm_usec].join('.')
  end

end

# == Schema Information
#
# Table name: job_logs
#
#  id      :integer          not null, primary key
#  job_id  :integer
#  tm      :integer
#  tm_usec :integer
#  data    :text
#

