class Job < ActiveRecord::Base

  belongs_to :build, class_name: "::Build"

  validates :build_id, :number, :status, presence: true
  validates :number, uniqueness: { scope: [:build_id] }

  default_scope ->{ order 'jobs.number DESC' }


  state_machine :status, initial: :initialized do

    state :initialized,   value: 0
    state :started,       value: 2
    state :finished,      value: 3
    state :failed,        value: 4
    state :errored,       value: 5

    event :start do
      transition :initialized => :started
    end

    event :finish do
      transition :started => :finished
    end

    event :decline do
      transition :started => :failed
    end

    event :error do
      transition [:initialized, :started] => :errored
    end
  end

  class << self

    def find_or_create_by_status_message(job_status_message)
      build = Build.find_by id: job_status_message.build_id
      if build
        find_job_for_status_message(build, job_status_message) ||
          create_job_for_status_message(build, job_status_message)
      end
    end

    def extract_matrix(job_status_message)
      if job_status_message.matrix
        job_status_message.matrix.inject({}) do |a,m|
          k,v = m.to_s.split("\:").map(&:strip)
          a[k.to_sym] = v
          a
        end
      else
        {}
      end
    end

    private

      def find_job_for_status_message(build, job_status_message)
        build.jobs.find_by(number: job_status_message.job_id)
      end

      def create_job_for_status_message(build, job_status_message)
        tm  = Time.at job_status_message.tm
        job = build.jobs.build number:     job_status_message.job_id,
                               started_at: tm,
                               matrix:     extract_matrix(job_status_message)

        job.save ? job : nil
      end

  end

  def as_json(*args)
    {
      id:           id,
      build_id:     build_id,
      number:       number,
      started_at:   started_at,
      finished_at:  finished_at,
      status:       status_name,
      matrix:       matrix
    }
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

