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
      project.user_repo = create(:user_repo)
      token = project.generate_token
      expect(project.hook_url).to eq "http://#{Rails.configuration.x.hostname}/callbacks/github/#{token}"
    end

    context "when user_repo is not exits" do
      it "should return nil" do
        project.user_repo = nil
        expect(project.hook_url).to be_nil
      end
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

  context "#subscribed_by?" do
    let(:project) { create :project }
    let(:user)    { project.user_repo.user }
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
    let(:user)    { project.user_repo.user }
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
    let(:user)    { project.user_repo.user }
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

  context "#new_build_from_payload" do
    let(:project) { create :project }
    let(:payload) { Vx::ServiceConnector::Model.test_payload }
    subject { project.new_build_from_payload payload }

    before { mock_file_request }

    context "a new build" do
      it { should be_new_record }
      its(:pull_request_id) { should be_nil }
      its(:branch)          { should eq 'master' }
      its(:branch_label)    { should eq 'master:label' }
      its(:sha)             { should eq 'HEAD' }
      its(:http_url)        { should eq 'http://example.com' }
      its(:author)          { should eq 'User Name' }
      its(:author_email)    { should eq 'me@example.com' }
      its(:message)         { should eq 'test commit' }
      its(:source)          { should eq 'content' }
    end

    def mock_file_request
      content = { "content" => Base64.encode64('content') }.to_json
      stub_request(:get, "https://api.github.com/repos/ci-worker-test-repo/contents/.travis.yml?ref=HEAD").
        to_return(:status => 200,
                  :body => content,
                  :headers => {"Content-Type" => "application/json"})
    end
  end

  context "#sc" do
    let(:user_repo) { create :user_repo }
    subject { project.sc }
    before { project.user_repo = user_repo }
    it { should be }
  end

  context "#sc_model" do
    subject { project.sc_model }

    context "when user_repo exists" do
      let(:user_repo) { create :user_repo }
      let(:project) { create :project, user_repo: user_repo }

      before do
        project.name = 'full/name'
      end
      it { should be }
      its(:id)         { should eq 1 }
      its(:full_name)  { should eq 'full/name' }
    end

    context "when user_repo is not exists" do
      it { should be_nil }
    end
  end

  context "#public_deploy_key" do
    subject { project.public_deploy_key }
    before do
      project.generate_deploy_key
    end
    it { should have(231).items }
  end

end

# == Schema Information
#
# Table name: projects
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  http_url     :string(255)      not null
#  clone_url    :string(255)      not null
#  description  :text
#  deploy_key   :text             not null
#  token        :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#  user_repo_id :integer          not null
#

