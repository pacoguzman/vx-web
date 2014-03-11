require 'securerandom'

class Project < ActiveRecord::Base

  include ::PublicUrl::Project

  belongs_to :user_repo, class_name: "::UserRepo", foreign_key: :user_repo_id
  has_many :builds, dependent: :destroy, class_name: "::Build"
  has_many :subscriptions, dependent: :destroy, class_name: "::ProjectSubscription"
  has_many :cached_files, dependent: :destroy

  validates :name, :http_url, :clone_url, :token,
    :deploy_key, presence: true
  validates :name, :token, uniqueness: true

  delegate :identity, to: :user_repo, allow_nil: true

  before_validation :generate_token,      on: :create
  before_validation :generate_deploy_key, on: :create

  after_destroy :publish_destroyed


  class << self
    def deploy_key_name
      "Vexor CI (#{Rails.configuration.x.hostname})"
    end

    def find_by_token(token)
      find_by token: token
    end
  end

  def builds_branch
    builds.select("DISTINCT ON (branch) #{Build.column_names.map{|c| "builds.#{c}"}.join(", ")}").reorder(:branch, number: :desc)
  end

  def to_s
    name
  end

  def deploy_key_name
    self.class.deploy_key_name
  end

  def public_deploy_key
    SSHKey.new(self.deploy_key).ssh_public_key
  end

  def generate_deploy_key
    SSHKey.generate(type: "RSA", bits: 1024).tap do |key|
      self.deploy_key = key.private_key.strip
    end
  end

  def generate_token
    self.token = SecureRandom.uuid
  end

  def hook_url
    if identity
      "http://#{Rails.configuration.x.hostname}/callbacks/#{identity.provider}/#{token}"
    end
  end

  def public_deploy_key
    @public_deploy_key ||= SSHKey.new(deploy_key, comment: deploy_key_name).try(:ssh_public_key)
  end

  def last_build
    builds.where.not(status: [0,1]).first
  end

  def update_last_build
    if build = last_build
      update(
        last_build_id:          build.id,
        last_build_at:          build.created_at,
        last_build_status_name: build.status_name
      )
    end
  end

  def subscribed_by?(user)
    !!subscriptions.where(user_id: user.id).pluck(:subscribe).first
  end

  def subscribe(user)
    subscription = find_or_build_subscription_for_user(user)
    subscription.update subscribe: true
  end

  def unsubscribe(user)
    subscription = find_or_build_subscription_for_user(user)
    subscription.update subscribe: false
  end

  def new_build_from_payload(payload)
    return unless sc

    file = sc.files(sc_model).get(payload.sha, ".travis.yml")

    attrs = {
      pull_request_id:  payload.pull_request_number,
      branch:           payload.branch,
      branch_label:     payload.branch_label,
      sha:              payload.sha,
      http_url:         payload.web_url,
      author:           payload.author,
      author_email:     payload.author_email,
      message:          payload.message,
      source:           file
    }

    builds.build(attrs)
  end

  def sc
    identity.try(:sc)
  end

  def sc_model
    if user_repo
      Vx::ServiceConnector::Model::Repo.new(user_repo.external_id, name)
    end
  end

  def build_payload(params)
    identity.sc.payload(sc_model, params)
  end

  private

    def find_or_build_subscription_for_user(user)
      subscription = subscriptions.find_by user_id: user.id
      subscription ||= subscriptions.build user: user
    end

    def publish_destroyed
      publish :destroyed
    end

end

# == Schema Information
#
# Table name: projects
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      not null
#  http_url               :string(255)      not null
#  clone_url              :string(255)      not null
#  description            :text
#  deploy_key             :text             not null
#  token                  :string(255)      not null
#  created_at             :datetime
#  updated_at             :datetime
#  user_repo_id           :integer
#  last_build_id          :integer
#  last_build_status_name :string(255)
#  last_build_at          :datetime
#

