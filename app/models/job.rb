class Job < ActiveRecord::Base

  belongs_to :build, class_name: "::Build"
  has_many :logs, class_name: "::JobLog", dependent: :destroy,
    extend: AppendLogMessage

  validates :build_id, :number, :status, presence: true
  validates :number, uniqueness: { scope: [:build_id] }

  after_create :publish_created

  default_scope ->{ order 'jobs.number DESC' }


  state_machine :status, initial: :initialized do

    state :initialized,   value: 0
    state :started,       value: 2
    state :passed,        value: 3
    state :failed,        value: 4
    state :errored,       value: 5

    event :start do
      transition [:initialized, :started] => :started
    end

    event :pass do
      transition :started => :passed
    end

    event :decline do
      transition :started => :failed
    end

    event :error do
      transition [:initialized, :started] => :errored
    end

    after_transition any => [:started, :passed, :failed, :errored] do |job, _|
      job.publish
    end
  end

  class << self

    def extract_matrix(job_status_message)
      if job_status_message.matrix
        job_status_message.matrix.inject({}) do |a,m|
          arr = m.to_s.split("\:").map(&:strip)
          k = arr.shift
          v = arr.join(":")
          a[k.to_sym] = v
          a
        end
      else
        {}
      end
    end


    def find_job_for_status_message(build, job_status_message)
      build.jobs.find_by(number: job_status_message.job_id)
    end

    def create_job_for_status_message(build, job_status_message)
      job = build.jobs.build number:     job_status_message.job_id,
                             matrix:     extract_matrix(job_status_message)

      job.save ? job : nil
    end
  end

  private

    def publish_created
      publish :created
    end

end

# == Schema Information
#
# Table name: jobs
#
#  id          :integer          not null, primary key
#  build_id    :integer          not null
#  number      :integer          not null
#  status      :integer          not null
#  matrix      :hstore
#  started_at  :datetime
#  finished_at :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

