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
    its("build.id") { should eq b.id }
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
      it { should eq 'Build #1 started' }
    end

    context "when build is passed" do
      let(:status) { 3 }
      it { should eq "Build #1 successed in 1s" }
    end

    context "when build is failed" do
      let(:status) { 4 }
      it { should eq "Build #1 failed in 1s" }
    end

    context "when build is errored" do
      let(:status) { 5 }
      it { should eq "Build #1 errored in 1s" }
    end
  end

  context "#build_url" do
    subject { notifier.build_url }

    before do
      mock(Rails.configuration.x).hostname { 'test.local' }
    end

    it { should eq "http://test.local/builds/#{b.id}" }
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
        with(:body => "{\"description\":\"#{notifier.description}\",\"target_url\":\"#{notifier.build_url}\",\"state\":\"success\"}").
        to_return(:status => 200, :body => "{}", :headers => {})
    end

  end
end
