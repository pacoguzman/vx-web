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
        create :build, status: 0, project: project, number: 1
        create :build, status: 2, project: project, number: 2
        create :build, status: 3, project: project, number: 3
        create :build, status: 4, project: project, number: 4
      end
      it { should eq :failed }
    end

    context "without builds" do
      it { should eq :unknown }
    end
  end

  context "#subscribed_by?" do
    let(:project) { create :project }
    let(:user)    { create :user }
    subject { project.subscribed_by?(user) }

    context "when user subscribed" do
      before do
        create :project_subscription, user: user, project: project
      end
      it { should be_true }
    end

    context "when user is not subscribed" do
      before do
        create :project_subscription, user: user, project: project, subscribe: false
      end
      it { should be_false }
    end

    context "when subscription does not exists" do
      it { should be_false }
    end
  end

end
