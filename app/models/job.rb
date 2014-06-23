class Job < ActiveRecord::Base

  include AASM

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

  aasm column: :status do
    state :initialized,   value: 0, initial: true
    state :started,       value: 2
    state :passed,        value: 3
    state :failed,        value: 4
    state :errored,       value: 5
    state :cancelled,     value: 6

    event :start do
      transitions from: [:initialized, :started], to: :started
    end

    event :pass do
      transitions from: :started, to: :passed
    end

    event :decline do
      transitions from: :started, to: :failed
    end

    event :error do
      transitions from: [:initialized, :started], to: :errored
    end

    event :cancel do
      transitions from: :initialized, to: :cancelled
    end
  end

  def aasm_event_fired(event, from, to)
    return unless [:started, :passed, :failed, :errored, :cancelled].include?(to)

    self.publish
  end

  def status_name
    status.to_sym
  end

  def regular?
    kind == 'regular'
  end

  def deploy?
    kind == 'deploy'
  end

  def self.status
    jobs = Job.where(status: ["initialized", "started"])
              .select("status, COUNT(id) AS count_ids")
              .group("status")
              .reorder("1")
    jobs.inject({}) do |a, job|
      a[job.status_name] = job.count_ids
      a
    end
  end

  def finished?
    ["passed", "failed", "errored"].include?(status)
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
      project_id:      build.project_id,
      build_id:        build.id,
      job_id:          number,
      name:            build.project.name,
      before_script:   script.to_before_script,
      script:          script.to_script,
      after_script:    script.to_after_script,
      image:           script.image
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
    if finished? or cancelled?
      transaction do
        self.started_at  = nil
        self.finished_at = nil
        self.status      = "initialized" # AASM initial state (self.class.aasm.initial_state)

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
#  kind        :string(255)
#

