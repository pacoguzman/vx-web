class Build < ActiveRecord::Base

  belongs_to :project

  validates :project_id, :number, :sha, :branch, presence: true
  validates :number, uniqueness: { scope: [:project_id] }


  before_validation :assign_number, on: :create
  before_validation :assign_sha,    on: :create
  before_validation :assign_branch, on: :create


  default_scope ->{ order 'builds.number DESC' }


  state_machine :status, initial: :initialized do

    state :initialized,   value: 0
    state :queued,        value: 1
    state :started,       value: 2
    state :finished,      value: 3
    state :failed,        value: 4
    state :errored,       value: 5

    event :in_queue do
      transition :initialized => :queued
    end

    event :start do
      transition :queued => :started
    end

    event :finish do
      transition :started => :finished
    end

    event :decline do
      transition :started => :failed
    end

    event :error do
      transition :started => :errored
    end
  end

  def as_json(*args)
    {
      id:          id,
      number:      number,
      sha:         sha,
      finished_at: finished_at,
      started_at:  started_at,
      status:      status_name,
      branch:      branch
    }
  end

  def to_perform_build_message
    Evrone::CI::Message::PerformBuild.new(
      id:         id,
      name:       project.name,
      src:        project.clone_url,
      sha:        sha,
      deploy_key: project.deploy_key,
    )
  end

  def publish_perform_build_message
    BuildsConsumer.publish to_perform_build_message.to_serialized_string
  end

  private

    def assign_number
      self.number = project.builds.maximum(:number).to_i + 1
    end

    def assign_sha
      self.sha ||= 'HEAD'
    end

    def assign_branch
      self.branch ||= 'master'
    end

end
