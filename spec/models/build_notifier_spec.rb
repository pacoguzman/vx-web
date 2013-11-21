require 'spec_helper'

describe BuildNotifier do
  let(:status) { 3 }
  let(:b)      { create :build, status: status, number: 1 }
  let(:attrs)  { JSON.parse(b.attributes.to_json) }
  let(:notifier) { described_class.new attrs }
  subject { notifier }

  it { should be }

  context "just created" do
    its(:message)  { should eq attrs }
  end

  context "#build" do
    subject { notifier.build }

    its(:status)  { should eq b.status }
    its(:frozen?) { should be_true }
  end

  context "#project" do
    subject { notifier.project }

    it { should eq b.project  }
  end

  context "#subscribed_emails" do
    let(:user) { create :user }
    let!(:sub) { create :project_subscription, user: user, project: b.project }
    subject { notifier.subscribed_emails }

    it { should eq %w{ email } }
  end

  context "#delivery_email_notifications" do
    subject { notifier.delivery_email_notifications }

    before do
      mock(notifier).subscribed_emails.twice { ["example@example.com"] }
      mock(notifier.build).notify? { true }
    end

    it { should be_true }

    it "should delivery email" do
      expect {
        subject
      }.to change(ActionMailer::Base.deliveries, :size).by(1)
      expect(ActionMailer::Base.deliveries.first.subject).to eq "[Passed] ci-worker-test-repo#1 (MyString - MyString)"
    end
  end

  context "#description" do
    subject { notifier.description }

    before do
      any_instance_of(Build) do |inst|
        stub(inst).duration { 1.1 }
      end
    end

    context "when build is started" do
      let(:status) { 2 }
      it { should eq 'EvroneCI build #1 started and still running' }
    end

    context "when build is passed" do
      let(:status) { 3 }
      it { should eq "EvroneCI build #1 is successfully completed in 1s" }
    end

    context "when build is failed" do
      let(:status) { 4 }
      it { should eq "EvroneCI build #1 failed in 1s" }
    end

    context "when build is errored" do
      let(:status) { 5 }
      it { should eq "EvroneCI build #1 broken in 1s" }
    end
  end

  context "(github)" do
    let(:identity) { create :user_identity, :github }
    before do
      b.project.update!(identity: identity)
    end

    context "#create_github_commit_status" do
      subject { notifier.create_github_commit_status }

      before do
        stub_github_commit_status_request
      end

      it { should be }

      context "when github identity not found" do
        let(:identity) { create :user_identity, provider: "not github" }
        it { should be_nil }
      end
    end

    context "#github_commit_status" do
      subject { notifier.github_commit_status }

      context "when build is started" do
        let(:status) { 2 }
        it { should eq 'pending' }
      end

      context "when build is passed" do
        let(:status) { 3 }
        it { should eq 'success' }
      end

      context "when build is failed" do
        let(:status) { 4 }
        it { should eq 'failure' }
      end

      context "when build is errored" do
        let(:status) { 5 }
        it { should eq 'error' }
      end
    end

    def stub_github_commit_status_request
      stub_request(:post, "https://api.github.com/repos/ci-worker-test-repo/statuses/MyString").
        with(:body => "{\"description\":\"#{notifier.description}\",\"target_url\":\"#{b.public_url}\",\"state\":\"success\"}").
        to_return(:status => 200, :body => "{}", :headers => {})
    end

  end
end
