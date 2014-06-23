require 'securerandom'

class Build < ActiveRecord::Base

  include AASM
  include ::PublicUrl::Build

  belongs_to :project, class_name: "::Project", touch: true
  has_many :jobs, class_name: "::Job", dependent: :destroy

  validates :project_id, :number, :sha, :branch, :source, :token, presence: true
  validates :number, uniqueness: { scope: [:project_id] }

  before_validation :assign_number,  on: :create
  before_validation :assign_sha,     on: :create
  before_validation :assign_branch,  on: :create
  before_validation :generate_token, on: :create

  after_create :publish_created

  default_scope ->{ order 'builds.number DESC' }
  scope :finished, -> { where(status: ["passed", "failed", "errored"]) }
  scope :pending, -> { where(status: ["started", "initialized"]).reorder('builds.updated_at DESC') } # TODO next Rails version allow not
  scope :with_pull_request, -> { where(arel_table[:pull_request_id].not_eq(nil)) }

  delegate :channel, to: :project, allow_nil: true

  aasm column: :status do

    state :initialized,   value: 0, initial: true
    state :started,       value: 2
    state :passed,        value: 3
    state :failed,        value: 4
    state :errored,       value: 5
    state :deploying,     value: 6

    event :start do
      transitions from: :initialized, to: :started
    end

    event :pass do
      transitions from: [:started, :deploying], to: :passed
    end

    event :decline do
      transitions from: [:started, :deploying], to: :failed
    end

    event :error do
      transitions from: [:initialized, :started, :deploying], to: :errored
    end

    event :deploy do
      transitions from: [:initialized, :started], to: :deploying
    end
  end

  def aasm_event_fired(event, from, to)
    return unless [:started, :passed, :failed, :errored, :deploying].include?(to)

    self.delivery_to_notifier

    self.publish
    self.update_last_build_on_project
    self.project.publish
  end

  def status_name
    status.to_sym
  end

  def source
    if s = read_attribute(:source)
      ::YAML.load(s)
    else
      {}
    end
  end

  def duration
    if started_at && finished_at
      finished_at - started_at
    end
  end

  def short_sha
    sha.to_s[0..8]
  end

  def prev_finished_build_in_branch
    @prev_finished_build_in_branch ||=
      self.class.finished
           .where(project_id: project_id)
           .where(branch: branch)
           .where("number < ?", number)
           .order("number DESC")
           .first
  end

  def finished?
    ["passed", "failed", "errored"].include?(status)
  end

  def status_has_changed?
    if finished?
      if prev_finished_build_in_branch
        prev_finished_build_in_branch.status != status
      else
        true
      end
    end
  end

  def notify?
    finished? &&
      (
        ["failed", "errored"].include?(status) ||
        (status_name == :passed && status_has_changed?)
      )
  end

  def to_builder_task(job)
    ::Vx::Builder::Task.new(
      name:             project.name,
      src:              project.clone_url,
      sha:              sha,
      build_id:         id,
      job_id:           job.number,
      deploy_key:       project.deploy_key,
      branch:           branch,
      pull_request_id:  pull_request_id,
      cache_url_prefix: cache_url_prefix
    )
  end

  def to_build_configuration
    ::Vx::Builder::BuildConfiguration.new(source)
  end

  def to_matrix
    @matrix ||= ::Vx::Builder.matrix(to_build_configuration)
  end

  def to_deploy
    @deploy ||= ::Vx::Builder.deploy(to_matrix, branch: branch)
  end

  def create_regular_jobs
    to_matrix.build.each_with_index do |config, idx|
      number = idx + 1
      job = self.jobs.regular.create(
        matrix: config.matrix_attributes,
        number: number,
        source: config.to_yaml,
      )
      return false unless job.persisted?
    end
    true
  end

  def create_deploy_jobs
    to_deploy.build.each_with_index do |config, idx|
      number = self.jobs.count + idx + 1
      job = self.jobs.deploy.create(
        matrix: config.matrix_attributes,
        number: number,
        source: config.to_yaml
      )
      return false unless job.persisted?
    end
    true
  end

  def publish_perform_job_messages
    if jobs.regular.any?
      jobs.regular.each(&:publish_perform_job_message)
    else
      publish_perform_deploy_job_messages
    end
    true
  end

  def publish_perform_deploy_job_messages
    jobs.deploy.each(&:publish_perform_job_message)
  end

  def subscribe_author
    email = self.author_email
    if email
      ProjectSubscription.subscribe_by_email(email, project)
    end
    true
  end

  def human_status_name
    @numan_status_name ||= begin
      case status_name
      when :passed
        if status_has_changed? && prev_finished_build_in_branch
          "Fixed"
        else
          status_name
        end
      when :errored
        if status_has_changed?
          'Broken'
        else
          "Still Broken"
        end
      when :failed
        if status_has_changed?
          status_name
        else
          "Still Failing"
        end
      else
        status_name
      end.to_s.titleize
    end
  end

  def restart
    if finished?
      transaction do
        Project.lock(true).find_by(id: project_id)
        self.started_at  = nil
        self.finished_at = nil
        self.status      = "initialized" # AASM initial state (self.class.aasm.initial_state)

        self.save.or_rollback_transaction

        self.jobs.each do |job|
          job.restart.or_rollback_transaction
        end

        publish_perform_job_messages

        self.publish
        self
      end
    end
  end

  def delivery_to_notifier
    ::BuildNotifyConsumer.publish(
      self.attributes,
      headers: {
        build_id: id
      }
    )
  end

  def update_last_build_on_project
    project.update_last_build
  end

  def publish(name = nil)
    super(name, channel: channel)
  end

  private

    def assign_number
      self.number ||= project.builds.maximum(:number).to_i + 1
    end

    def assign_sha
      self.sha ||= 'HEAD'
    end

    def assign_branch
      self.branch ||= 'master'
    end

    def generate_token
      self.token ||= SecureRandom.uuid
    end

    def publish_created
      publish :created
    end

end

# == Schema Information
#
# Table name: builds
#
#  id              :integer          not null, primary key
#  number          :integer          not null
#  project_id      :integer          not null
#  sha             :string(255)      not null
#  branch          :string(255)      not null
#  pull_request_id :integer
#  author          :string(255)
#  message         :text
#  status          :integer          default(0), not null
#  started_at      :datetime
#  finished_at     :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  author_email    :string(255)
#  http_url        :string(255)
#  branch_label    :string(255)
#  source          :text             not null
#  token           :string(255)      not null
#

