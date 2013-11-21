require 'spec_helper'

describe JobUpdater do
  let(:message_attributes) { {} }
  let(:message)  {
    Evrone::CI::Message::JobStatus.test_message(
      message_attributes
    )
  }
  let(:updater) { described_class.new message }
  subject { updater }

  context "just created" do
    its(:message) { should eq message }
  end

  context "perform" do
    let(:b) { create :build }
    let(:message_attributes) { { build_id: b.id } }
    subject { updater.perform ; updater }

    it "should find and assign build" do
      expect(subject.build).to eq b
    end

    it "should create job if it does not exists" do
      expect{
        subject
      }.to change(b.jobs, :count).by(1)
      expect(subject.job).to be
    end

    it "should reuse job if it exists" do
      job = create :job, build: b, number: message.job_id
      expect{
        subject
      }.to_not change(b.jobs, :count)
      expect(subject.job).to eq job
    end

    context "truncate job logs" do
      let(:message_attributes) { {
        build_id: b.id,
        status: status,
        job_id: job.number
      } }
      let(:job) { create :job, build: b, status: 2 }
      let!(:log) { create :job_log, job: job }

      context "when status STARTED" do
        let(:status) { 2 }

        it "should delete all job logs" do
          expect {
            subject
          }.to change(job.logs, :count).from(1).to(0)
        end
      end

      context "when status FINISHED" do
        let(:status) { 3 }

        it "cannot touch job logs" do
          expect {
            subject
          }.to_not change(job.logs, :count)
        end
      end

      context "when status FAILED" do
        let(:status) { 4 }

        it "cannot touch job logs" do
          expect {
            subject
          }.to_not change(job.logs, :count)
        end
      end
    end

    context "finalize build" do
      let(:job1_status) { 2 }
      let(:job2_status) { 2 }
      let(:job1) { create :job, build: b, number: 1, status: 2 }
      let(:job2) { create :job, build: b, number: 2, status: job2_status }
      let(:message_attributes) { {
        build_id:   b.id,
        job_id:     job1.number,
        status:     job1_status,
      } }
      before do
        [job1, job2]
        b.update_attributes jobs_count: 2, status: 2
        subject; b.reload
      end

      context "when all jobs finished" do
        let(:job1_status) { 3 }
        let(:job2_status) { 3 }
        it "should finish build" do
          expect(b.status_name).to eq :passed
          expect(b.finished_at).to be
        end
      end

      context "when all jobs complete and any job failed" do
        let(:job1_status) { 3 }
        let(:job2_status) { 4 }
        it "should finish build" do
          expect(b.status_name).to eq :failed
          expect(b.finished_at).to be
        end
      end

      context "when all jobs complete and any job errored" do
        let(:job1_status) { 3 }
        let(:job2_status) { 5 }
        it "should finish build" do
          expect(b.status_name).to eq :errored
          expect(b.finished_at).to be
        end
      end

      context "when any of jobs incomplete" do
        let(:job1_status) { 2 }
        let(:job2_status) { 3 }
        it "cannot touch build" do
          expect(b.status_name).to eq :started
          expect(b.finished_at).to be_nil
        end
      end
    end

    context "start build" do
      let(:message_attributes) { {
        build_id: b.id,
        status: status
      } }
      before { subject; b.reload }

      context "if message status is STARTED and build is initialized" do
        let(:status) { 2 }
        it "should start build" do
          expect(b.status_name).to eq :started
          expect(b.started_at).to be
        end
      end

      context "when message status is not STARTED" do
        let(:status) { 0 }
        it "cannot start build" do
          expect(b.status_name).to eq :initialized
        end
      end

      context "when build passed" do
        let(:status) { 0 }
        before do
          b.start!
          b.pass!
          b.reload
        end
        it "cannot start build" do
          expect(b.status_name).to eq :passed
        end
      end
    end

    context "update job status" do
      let(:job) { create :job, build: b }
      let(:message_attributes) { {
        status: status,
        build_id: b.id,
        job_id: job.number
      } }

      before do
        subject
        job.reload
      end

      context "when status INITIALIZED" do
        let(:status) { 0 }
        it "should do nothing" do
          expect(job.status_name).to eq :initialized
          expect(job.started_at).to be_nil
          expect(job.finished_at).to be_nil
        end
      end

      context "when status STARTED" do
        let(:status) { 2 }
        it "should start job" do
          expect(job.status_name).to eq :started
          expect(job.started_at).to be
          expect(job.finished_at).to be_nil
        end
      end

      context "when status FAILED" do
        let(:job) { create :job, build: b, status: 2 }
        let(:status) { 4 }
        it "should decline job" do
          expect(job.status_name).to eq :failed
          expect(job.finished_at).to be
        end
      end

      context "when status ERRORED" do
        let(:job) { create :job, build: b, status: 2 }
        let(:status) { 5 }
        it "should error job" do
          expect(job.status_name).to eq :errored
          expect(job.finished_at).to be
        end
      end
    end

  end

end
