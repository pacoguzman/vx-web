class Build < ActiveRecord::Base

  include ::PublicUrl::Build

  belongs_to :project, class_name: "::Project", touch: true
  has_many :jobs, class_name: "::Job", dependent: :destroy

  validates :project_id, :number, :sha, :branch, :source, presence: true
  validates :number, uniqueness: { scope: [:project_id] }

  before_validation :assign_number, on: :create
  before_validation :assign_sha,    on: :create
  before_validation :assign_branch, on: :create

  after_create :publish_created

  default_scope ->{ order 'builds.number DESC' }
  scope :finished, -> { where(status: [3,4,5]) }

  state_machine :status, initial: :initialized do

    state :initialized,   value: 0
    state :started,       value: 2
    state :passed,        value: 3
    state :failed,        value: 4
    state :errored,       value: 5

    event :start do
      transition :initialized => :started
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

    after_transition any => [:started, :passed, :failed, :errored] do |build, transition|
      build.delivery_to_notifier

      build.publish
      build.update_last_build_on_project
      build.project.publish
    end
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

  def to_builder_task
    ::Vx::Builder::Task.new(
      project.name,
      project.clone_url,
      sha,
      deploy_key:       project.deploy_key,
      branch:           branch,
      pull_request_id:  pull_request_id,
      cache_url_prefix: cache_url_prefix
    )
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
    [3,4,5].include?(status)
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
        [4,5].include?(status) ||
        (status_name == :passed && status_has_changed?)
      )
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
        self.status      = 0

        self.save.or_rollback_transaction

        self.jobs.each do |job|
          job.restart.or_rollback_transaction
        end

        self.publish
        self
      end
    end
  end

  def delivery_to_notifier
    ::BuildNotifyConsumer.publish self.attributes
  end

  def update_last_build_on_project
    project.update_last_build
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
#  message         :string(255)
#  status          :integer          default(0), not null
#  started_at      :datetime
#  finished_at     :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  author_email    :string(255)
#  http_url        :string(255)
#  branch_label    :string(255)
#  source          :text             not null
#

