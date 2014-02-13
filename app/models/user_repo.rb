class UserRepo < ActiveRecord::Base

  SETTINGS_URL = {
    "github" => "%s/settings/hooks",
    'gitlab' => "%s/hooks",
  }

  PROVIDER_TITLE = {
    'github' => "Github",
    'gitlab' => 'Gitlab',
  }

  belongs_to :identity, class_name: "::UserIdentity", foreign_key: :identity_id
  has_one :project, dependent: :nullify
  has_many :same_name_projects, ->{ readonly }, class_name: "::Project",
    foreign_key: :name, primary_key: :full_name

  validates :full_name, :ssh_url, :html_url, :external_id, presence: true
  validates :is_private, inclusion: { in: [true, false] }
  validates :identity_id, uniqueness: { scope: [:external_id] }

  delegate :provider, :user, to: :identity

  default_scope ->{ order("user_repos.full_name ASC") }

  class << self
    def find_or_create_by_sc(identity, model)
      repo = find_or_initialize_by(external_id: model.id, identity: identity)
      repo.assign_attributes(
        full_name:    model.full_name,
        is_private:   model.is_private,
        ssh_url:      model.ssh_url,
        html_url:     model.html_url,
        description:  model.description
      )
      repo.save && repo
    end
  end

  def subscribe
    transaction do

      update_attribute(:subscribed, true).or_rollback_transaction

      unless project
        new_project = create_project.or_rollback_transaction
        yield new_project if block_given?
      end

      unsubscribe_project
      subscribe_project

      true
    end
  end

  def unsubscribe
    transaction do

      update_attribute(:subscribed, false).or_rollback_transaction

      if project
        unsubscribe_project
        project.destroy
      end

      true
    end
  end

  def settings_url
    SETTINGS_URL[provider.to_s] % html_url
  end

  def provider_title
    PROVIDER_TITLE[provider.to_s]
  end

  private

    def unsubscribe_project
      sc = identity.sc
      sc.hooks(project.sc_model).destroy(Rails.configuration.x.hostname)
      sc.deploy_keys(project.sc_model).destroy(project.deploy_key_name)
    end

    def subscribe_project
      sc = identity.sc

      sc.hooks(project.sc_model).create(
        project.hook_url,
        project.token
      )
      sc.deploy_keys(project.sc_model).create(
        project.deploy_key_name,
        project.public_deploy_key
      )
    end

    def create_project
      attrs = {
        name:        full_name,
        http_url:    html_url,
        clone_url:   ssh_url,
        description: description
      }
      build_project attrs
      project.save && project
    end

end

# == Schema Information
#
# Table name: user_repos
#
#  id                 :integer          not null, primary key
#  organization_login :string(255)
#  full_name          :string(255)      not null
#  is_private         :boolean          not null
#  ssh_url            :string(255)      not null
#  html_url           :string(255)      not null
#  subscribed         :boolean          default(FALSE), not null
#  description        :text
#  created_at         :datetime
#  updated_at         :datetime
#  identity_id        :integer          not null
#  external_id        :integer          not null
#

