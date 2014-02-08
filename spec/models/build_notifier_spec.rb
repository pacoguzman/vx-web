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

  context "#notify" do
    subject { notifier.notify }
    before do
      mock(notifier.project.sc).notices(anything).mock!.create(
        b.sha,
        :passed,
        b.public_url,
        anything
      )
    end
    it { should be }
  end

  context "#subscribed_emails" do
    let(:user) { b.project.user_repo.user }
    let!(:sub) { create :project_subscription, user: user, project: b.project }
    subject { notifier.subscribed_emails }

    it { should eq ["\"name\" <email>"] }
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
      it { should eq 'Vexor CI: build #1 started and still running' }
    end

    context "when build is passed" do
      let(:status) { 3 }
      it { should eq "Vexor CI: build #1 is successfully completed in 1s" }
    end

    context "when build is failed" do
      let(:status) { 4 }
      it { should eq "Vexor CI: build #1 failed in 1s" }
    end

    context "when build is errored" do
      let(:status) { 5 }
      it { should eq "Vexor CI: build #1 broken in 1s" }
    end
  end

end
