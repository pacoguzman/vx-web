require 'spec_helper'

describe BuildNotifier do
  let(:status) { 3 }
  let(:b)      { create :build, status: status, number: 1 }
  let(:notifier) { described_class.new b.id, b.status_name }
  subject { notifier }

  it { should be }

  context "just created" do
    its(:build_id)  { should eq b.id }
    its(:status)    { should eq 'passed' }
  end

  context "#build" do
    subject { notifier.build }

    context "when build found" do
      it { should eq b }
    end

    context "when build is not found" do
      let(:notifier) { described_class.new b.id + 1, b.status_name }
      it { should be_nil }
    end
  end

  context "#project" do
    subject { notifier.project }

    context "when build found" do
      it { should eq b.project  }
    end

    context "when build is not found" do
      let(:notifier) { described_class.new b.id + 1, b.status_name }
      it { should be_nil }
    end
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
      it { should eq 'EvroneCI build #1 started' }
    end

    context "when build is passed" do
      let(:status) { 3 }
      it { should eq "EvroneCI build #1 successed" }
    end

    context "when build is failed" do
      let(:status) { 4 }
      it { should eq "EvroneCI build #1 failed" }
    end

    context "when build is errored" do
      let(:status) { 5 }
      it { should eq "EvroneCI build #1 broken" }
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
