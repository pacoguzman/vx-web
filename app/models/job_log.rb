class JobLog < ActiveRecord::Base

  belongs_to :job

  validates :job_id, :tm, presence: true

  default_scope ->{ order("job_logs.tm ASC") }

  def id
    [job_id, tm].join('.')
  end

end

# == Schema Information
#
# Table name: job_logs
#
#  id     :integer          not null, primary key
#  job_id :integer
#  tm     :integer
#  data   :text
#

