class Job < ActiveRecord::Base

  belongs_to :build, class_name: "::Build"
  has_one :project, through: :build
  has_one :company, through: :project
  has_many :logs, class_name: "::JobLog", dependent: :delete_all,
    extend: AppendLogMessage

  validates :build_id, :number, :status, :source, :kind, presence: true
  validates :number, uniqueness: { scope: [:build_id] }
  validates :kind, inclusion: { in: %w{ regular deploy } }

  after_create :publish_created

  default_scope ->{ order 'jobs.number ASC' }

  scope :regular, ->{ where(kind: "regular") }
  scope :deploy,  ->{ where(kind: "deploy") }

  delegate :channel, to: :build, allow_nil: true

  state_machine :status, initial: :initialized do

    state :initialized,   value: 0
    state :started,       value: 2
    state :passed,        value: 3
    state :failed,        value: 4
    state :errored,       value: 5
    state :cancelled,     value: 6

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

    event :cancel do
      transition [:initialized] => :cancelled
    end

    after_transition any => [:started, :passed, :failed, :errored, :cancelled] do |job, _|
      job.publish
    end
  end

  def duration
    if finished_at && started_at
      (finished_at - started_at).to_i
    else
      0
    end
  end

  def regular?
    kind == 'regular'
  end

  def deploy?
    kind == 'deploy'
  end

  def self.status
    jobs = Job.where(status: [0,2])
              .select("status, COUNT(id) AS count_ids")
              .group("status")
              .reorder("1")
    jobs.inject({}) do |a, job|
      a[job.status_name] = job.count_ids
      a
    end
  end

  def finished?
    [3,4,5].include?(status)
  end

  def to_builder_source
    ::Vx::Builder::BuildConfiguration.from_yaml(source)
  end

  def to_script_builder
    ::Vx::Builder.script(build.to_builder_task(self), to_builder_source)
  end

  def to_perform_job_message
    script = to_script_builder
    ::Vx::Message::PerformJob.new(
      company_id:      company.id,
      company_name:    company.name,

      project_id:      project.id.to_s,
      project_name:    project.name,

      build_id:        build.id.to_s,
      build_number:    build.number,

      job_id:          id.to_s,
      job_number:      number,
      job_version:     1,

      before_script:   script.to_before_script,
      script:          script.to_script,
      after_script:    script.to_after_script,
      image:           script.image,
      job_timeout:     script.vexor.timeout,
      job_read_timeout:script.vexor.read_timeout
    )
  end

  def publish_perform_job_message
    ::JobsConsumer.publish(
      to_perform_job_message,
      headers: {
        company_id:      company.id,
        company_name:    company.name,

        project_id:      project.id.to_s,
        project_name:    project.name,

        build_id:        build.id.to_s,
        build_number:    build.number,

        job_id:          id,
        job_number:      number,
        job_version:     1,
      }
    )
  end

  def restart
    if finished? or cancelled?
      transaction do
        self.started_at  = nil
        self.finished_at = nil
        self.status      = 0

        self.logs.delete_all
        self.save.or_rollback_transaction
        self.publish
        self
      end
    end
  end

  def publish(event = nil)
    super(event, channel: channel)
  end

  def create_job_history!
    if finished?
      JobHistory.create!(
        company:      company,
        project_name: project.name,
        build_number: build.number,
        job_number:   number,
        duration:     duration,
        created_at:   finished_at
      )
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
#  number      :integer          not null
#  status      :integer          not null
#  matrix      :hstore
#  started_at  :datetime
#  finished_at :datetime
#  created_at  :datetime
#  updated_at  :datetime
#  source      :text             not null
#  kind        :string(255)      not null
#  build_id    :uuid             not null
#  id          :uuid             not null, primary key
#

