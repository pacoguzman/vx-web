require 'spec_helper'

describe JobLogsUpdater do
  let(:build)   { create :build }
  let(:job)     { create :job, build: build }
  let(:message) { Evrone::CI::Message::JobLog.test_message build_id: build.id, job_id: job.number }
  let(:updater) { described_class.new message }
  subject { updater }

  context "just created" do
    its(:message) { should eq message }
    its(:build)   { should eq build }
    its(:job)     { should eq job }
  end

  context "perform" do
    subject { updater.perform }
    it { should be }
  end
end
