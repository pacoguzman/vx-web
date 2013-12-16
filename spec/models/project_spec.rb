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

    it { should match(/\=\= Vexor \(.*\)/) }
  end

  context ".deploy_key_name" do
    subject { Project.deploy_key_name }
    it { should match(/Vexor \(.*\)/) }
  end

  context "#deploy_key_name" do
    subject { project.deploy_key_name }
    it { should match(/Vexor \(.*\)/) }
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

  context "#last_build" do
    let(:project) { create :project }
    subject { project.last_build }

    context "with builds" do
      before do
        create :build, status: 0, project: project, number: 1
        create :build, status: 2, project: project, number: 2
        create :build, status: 3, project: project, number: 3
        create :build, status: 4, project: project, number: 4
      end
      its(:number) { should eq 4 }
    end

    context "without builds" do
      it { should be_nil }
    end
  end

  context "#last_build_status" do
    let(:build) { Build.new status: 4 }
    subject { project.last_build_status }

    context "with builds" do
      before do
        mock(project).last_build.twice { build }
      end
      it { should eq :failed }
    end

    context "without builds" do
      it { should eq :unknown }
    end
  end

  context "#last_build_created_at" do
    let(:tm) { Time.now }
    let(:build) { Build.new created_at: tm }
    subject { project.last_build_created_at }

    context "with builds" do
      before do
        mock(project).last_build.twice { build }
      end
      it { should eq tm }
    end

    context "without builds" do
      it { should be_nil }
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

  context "#subscribe" do
    let(:project) { create :project }
    let(:user)    { create :user }
    subject { project.subscribe(user) }

    context "when subscription exists" do
      let!(:sub) { create :project_subscription, user: user, project: project, subscribe: false }
      it { should be_true }
      it "should subscribe user" do
        expect {
          subject
        }.to change{ sub.reload.subscribe }.to(true)
      end
    end

    context "when subscription does not exists" do
      it { should be_true }
      it "should subscribe user" do
        expect {
          subject
        }.to change(project.subscriptions, :count).by(1)
        expect(project.subscriptions.first.subscribe).to be_true
        expect(project.subscriptions.first.user).to eq user
      end
    end
  end

  context "#unsubscribe" do
    let(:project) { create :project }
    let(:user)    { create :user }
    subject { project.unsubscribe(user) }

    context "when subscription exists" do
      let!(:sub) { create :project_subscription, user: user, project: project, subscribe: true }
      it { should be_true }
      it "should unsubscribe user" do
        expect {
          subject
        }.to change{ sub.reload.subscribe }.to(false)
      end
    end

    context "when subscription does not exists" do
      it { should be_true }
      it "should unsubscribe user" do
        expect {
          subject
        }.to change(project.subscriptions, :count).by(1)
        expect(project.subscriptions.first.subscribe).to be_false
        expect(project.subscriptions.first.user).to eq user
      end
    end
  end

end
