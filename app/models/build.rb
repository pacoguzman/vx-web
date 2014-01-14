class Build < ActiveRecord::Base

  include ::BuildMessages
  include ::PublicUrl::Build

  belongs_to :project, class_name: "::Project"
  has_many :jobs, class_name: "::Job", dependent: :destroy

  validates :project_id, :number, :sha, :branch, presence: true
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
      build.project.publish
    end
  end

  def find_or_create_job_by_status_message(job_status_message)
    Job.find_job_for_status_message(self, job_status_message) ||
      Job.create_job_for_status_message(self, job_status_message)
  end

  def source
    @unpacked_source ||= begin
      if s = read_attribute(:source)
        ::YAML.load(s)
      else
        {}
      end
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
      Build.finished
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
        self.started_at  = nil
        self.finished_at = nil
        self.status      = 0
        self.jobs_count  = 0

        self.jobs.each do |job|
          job.destroy.or_rollback_transaction
        end

        self.save.or_rollback_transaction

        self.publish
        self.jobs.each do |job|
          job.publish :destroyed
        end

        self.delivery_to_fetcher
        self
      end
    end
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
#  jobs_count      :integer          default(0), not null
#  http_url        :string(255)
#  branch_label    :string(255)
#

