require 'spec_helper'

describe Project do
  let(:project) { Project.new }

  context "#public_deploy_key" do
    subject { project.public_deploy_key }
    before { project.generate_deploy_key }

    it { should match(/\=\= evrone\.ci/) }
  end

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

  context "#hook_url" do
    it "should return secure hook url for project" do
      token = project.generate_token
      expect(project.hook_url).to eq "http://#{Rails.configuration.x.hostname}/github/callback/#{token}"
    end
  end
end
