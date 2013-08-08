require 'securerandom'
require 'socket'

class Project < ActiveRecord::Base

  include Github::Project

  validates :name, :http_url, :clone_url, :provider, :token,
    :deploy_key, presence: true
  validates :provider, inclusion: { in: %w{ github } }
  validates :name, uniqueness: true

  before_validation :generate_token,      on: :create
  before_validation :generate_deploy_key, on: :create


  class << self
    def deploy_key_name ; 'evrone.ci' end
  end


  def deploy_key_name
    self.class.deploy_key_name
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
    "http://#{Rails.configuration.x.hostname}/github/callback/#{token}"
  end

  def public_deploy_key
    @public_deploy_key ||= SSHKey.new(deploy_key, comment: deploy_key_name).then do
      ssh_public_key
    end
  end

end
