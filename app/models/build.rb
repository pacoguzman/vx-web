class Build < ActiveRecord::Base

  include BuildSerializable
  include BuildMessages


  belongs_to :project, class_name: "::Project"

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
      transition [:initialized, :queued, :started] => :errored
    end
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
#

