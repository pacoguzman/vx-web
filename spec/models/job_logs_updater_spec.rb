require 'spec_helper'

describe JobLogsUpdater do
  let(:build)   { create :build }
  let(:job)     { create :job, build: build }
  let(:message) { Vx::Message::JobLog.test_message job_id: job.id }
  let(:updater) { described_class.new message }
  subject { updater }

  context "just created" do
    its(:message) { should eq message }
    its(:job)     { should eq job }
  end

  context "perform" do
    subject { updater.perform }
    it { should be }

    it "should create log entry" do
      expect{ subject }.to change(JobLog, :count).by(1)
      expect(job.logs.map(&:data)).to eq [message.log]
      expect(job.logs.map(&:tm)).to eq   [message.tm]
    end
  end
end
