class JobHistory < ActiveRecord::Base
  belongs_to :company

  default_scope ->{ order("job_histories.created_at") }

  validates :duration, :company, :build_number, :job_number, presence: true
end

# == Schema Information
#
# Table name: job_histories
#
#  company_id   :uuid             not null
#  duration     :integer          not null
#  project_name :string(255)      not null
#  build_number :integer          not null
#  job_number   :integer          not null
#  created_at   :datetime         not null
#

