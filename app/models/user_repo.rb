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
  belongs_to :company

  has_one :project, dependent: :destroy
  has_one :user, through: :identity

  validates :full_name, :ssh_url, :html_url, :external_id, presence: true
  validates :is_private, inclusion: { in: [true, false] }

  delegate :provider, :user, to: :identity

  default_scope ->{ order("user_repos.full_name ASC") }

  scope :in_company, ->(company) {
    if company
      where(company: company)
    else
      self
    end
  }

  class << self
    def find_or_create_by_sc(company, identity, model)
      repo = find_or_initialize_by(
        external_id: model.id,
        identity:    identity,
        company:     company
      )
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

  def same_name_projects?
    Project.where(company: company, name: self.full_name).any?
  end

  def subscribe
    unless identity.ignored?
      transaction do

        update_attribute(:subscribed, true).or_rollback_transaction

        new_project = nil

        unless project
          new_project = create_project.or_rollback_transaction
        end

        unsubscribe_project
        subscribe_project

        if new_project and block_given?
          yield new_project
        end

        true
      end
    end
  end

  def unsubscribe
    transaction do

      update_attribute(:subscribed, false).or_rollback_transaction

      if project
        unless identity.ignored?
          unsubscribe_project
        end
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

  # TODO: test it
  def unsubscribe_project
    if project
      sc = identity.sc
      sc.hooks(project.sc_model).destroy(Rails.configuration.x.hostname.host)
      sc.deploy_keys(project.sc_model).destroy(project.deploy_key_name)
    end
  end

  private

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
        description: description,
        company_id:  company_id
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
#  company_id         :uuid             not null
#

