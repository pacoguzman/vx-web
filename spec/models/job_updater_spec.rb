require 'spec_helper'

describe JobUpdater do
  let(:status) { 2 }
  let(:message_attributes) { {
    status: status,
    project_id: uuid_for(1),
    build_id: uuid_for(2),
    job_id: uuid_for(3)
  } }
  let(:message)  {
    Vx::Message::JobStatus.test_message(
      message_attributes
    )
  }
  let(:project) { create :project, id: message.project_id }
  let(:b)       { create :build,   id: message.build_id, project: project }
  let(:job)     { create :job,     id: message.job_id,   build: b }
  let(:updater) { described_class.new message }
  subject { updater }

  context "just created" do
    its(:project) { should eq project }
    its(:build)   { should eq b }
    its(:job)     { should eq job }
    its(:message) { should eq message }
  end

  context "perform" do
    subject { updater.perform }
    before { job }

    it { should be }

    context "when status is STARTED" do
      let(:status) { 2 }

      it "should update and save job status" do
        expect {
          subject
        }.to change(updater.job, :status_name).to(:started)
        expect(updater.job.started_at).to eq Time.at(message.tm)
      end

      it "should truncate job logs" do
        updater.job.logs.create! tm: 1, data: "data"
        expect {
          subject
        }.to change(updater.job.logs, :count).to(0)
      end

      it "should start build" do
        expect {
          subject
        }.to change(updater.build, :status_name).to(:started)
        expect(updater.build.started_at).to eq Time.at(message.tm)
      end
    end

    context "when status is FINISHED" do
      let(:status) { 3 }

      before do
        b.start!
        job.start!
      end

      it "should create job history" do
        expect {
          subject
        }.to change(JobHistory, :count).by(1)
      end

      it "should update and save job status" do
        expect {
          subject
        }.to change(updater.job, :status_name).to(:passed)
        expect(updater.job.finished_at).to eq Time.at(message.tm)
      end

      it "should finish build" do
        expect {
          subject
        }.to change(updater.build, :status_name).to(:passed)
        expect(updater.build.finished_at).to eq Time.at(message.tm)
      end

      context "when have failed job" do
        before do
          create :job, build: b, status: "failed", number: 2
        end

        it "should fail build" do
          expect {
            subject
          }.to change(updater.build, :status_name).to(:failed)
          expect(updater.build.finished_at).to eq Time.at(message.tm)
        end
      end

      context "when have pending jobs" do
        before do
          create :job, build: b, status: "started", number: 2
        end

        it "should keep build" do
          expect {
            subject
          }.to_not change(updater.build, :status_name)
          expect(updater.build.finished_at).to be_nil
        end
      end
    end

    context "when build is not found" do
      before do
        b.destroy
      end

      it { should be_nil }
    end

    context "when job is not found" do
      before do
        job.destroy
      end

      it { should be_nil }
    end

    context "when job already finished" do
      let(:status) { 3 }

      before do
        b.start! && b.pass!
        job.start! && job.pass!
      end

      it { should eq :invalid_transition }
    end
  end
end
