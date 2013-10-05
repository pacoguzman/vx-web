require 'spec_helper'

describe Project do
  let(:project) { Project.new }

  context ".find_by_token" do
    let(:token)   { project.token   }
    let(:project) { create :project }

    subject { Project.find_by_token token }

    context "successfuly" do
      it { should eq project }
    end

    context "fail" do
      let(:token) { 'not exits' }
      it { should be_nil }
    end
  end

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

  context "#last_build_status" do
    let(:project) { create :project }
    subject { project.last_build_status }

    context "with builds" do
      before do
        create :build, status: 0, project: project
        create :build, status: 2, project: project
        create :build, status: 3, project: project
        create :build, status: 4, project: project
      end
      it { should eq :failed }
    end

    context "without builds" do
      it { should eq :unknown }
    end
  end

end
