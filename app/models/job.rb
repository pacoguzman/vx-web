class Job < ActiveRecord::Base

  belongs_to :build, class_name: "::Build"
  has_many :logs, class_name: "::JobLog", dependent: :delete_all,
    extend: AppendLogMessage

  validates :build_id, :number, :status, :source, presence: true
  validates :number, uniqueness: { scope: [:build_id] }

  after_create :publish_created

  default_scope ->{ order 'jobs.number ASC' }


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

  def finished?
    [3,4,5].include?(status)
  end

  def to_builder_script
    ::Vx::Builder::Script.new(build.to_builder_task, to_builder_source)
  end

  def to_builder_source
    ::Vx::Builder::Source.from_yaml(source)
  end

  def to_perform_job_message
    script = to_builder_script
    ::Vx::Message::PerformJob.new(
      project_id:      build.project_id,
      id:              build.id,
      job_id:          number,
      name:            build.project.name,
      before_script:   script.to_before_script,
      script:          script.to_script,
      after_script:    script.to_after_script
    )
  end

  def publish_perform_job_message
    ::JobsConsumer.publish(
      to_perform_job_message,
      headers: {
        build_id: build.id,
        job_id:   number
      }
    )
  end

  def restart
    if finished?
      transaction do
        self.started_at  = nil
        self.finished_at = nil
        self.status      = 0

        self.logs.delete_all
        self.save.or_rollback_transaction
        self.publish_perform_job_message
        self.publish
        self
      end
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
#  source      :text             not null
#

