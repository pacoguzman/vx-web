class Project < ActiveRecord::Base

  include Github::Project

  validates :name, :http_url, :clone_url, :provider, presence: true
  validates :provider, inclusion: { in: %w{ github } }
  validates :name, uniqueness: true


  class << self
    def deploy_key_name ; 'evrone.ci' end
  end

  def deploy_key_name
    self.class.deploy_key_name
  end

  def generate_deploy_key!
    SSHKey.generate(type: "RSA", bits: 1024).tap do |key|
      self.deploy_key = key.private_key.strip
    end
  end

end
