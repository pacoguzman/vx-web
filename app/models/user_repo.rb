class UserRepo < ActiveRecord::Base

  belongs_to :identity, class_name: "::UserIdentity", foreign_key: :identity_id
  has_one :project, dependent: :nullify

  validates :full_name, :ssh_url, :html_url, presence: true
  validates :is_private, inclusion: { in: [true, false] }
  validates :full_name, uniqueness: { scope: [:identity_id] }

  delegate :user, to: :identity

  default_scope ->{ order("user_repos.full_name ASC") }

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

  private

    def unsubscribe_project
      model = project.to_service_connector_model
      conn  = identity.service_connector

      conn.hooks(model).destroy(Rails.configuration.x.hostname)
      conn.deploy_keys(model).destroy(project.deploy_key_name)
    end

    def subscribe_project
      model = project.to_service_connector_model
      conn  = identity.service_connector

      conn.hooks(model).create(
        project.hook_url,
        project.token
      )
      conn.deploy_keys(model).create(
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
#  user_id            :integer          not null
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
#

