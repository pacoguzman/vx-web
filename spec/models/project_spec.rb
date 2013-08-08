require 'spec_helper'

describe Project do
  let(:project) { Project.new }

  context ".deploy_key_name" do
    subject { Project.deploy_key_name }
    it { should eq 'evrone.ci' }
  end

  context "#deploy_key_name" do
    subject { project.deploy_key_name }
    it { should eq 'evrone.ci' }
  end

  context "#generate_deploy_key" do
    it "should create a new deploy key for project" do
      expect {
        project.generate_deploy_key
      }.to change(project, :deploy_key).to(/RSA PRIVATE KEY/)
    end
  end

  context "#generate_token" do
    it "should create a new secure token for project" do
      expect {
        project.generate_token
      }.to change(project, :token).to(/^\w{8}/)
    end
  end
end
