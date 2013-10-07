require 'spec_helper'

describe JobUpdater do
  let(:message_attributes) { {} }
  let(:message)  {
    Evrone::CI::Message::JobStatus.test_message(
      message_attributes
    )
  }
  let(:job)     { build :job, build: b        }
  let(:b)       { create :build               }
  let(:updater) { described_class.new message }
  subject { updater }

  before do
    mock(Build).find_by(id: message.build_id) { b }
    mock(Job).find_or_create_by_status_message(message) { job }
  end

  context "just created" do
    its(:message) { should eq message }
    its(:job)     { should eq job     }
    its(:build)   { should eq b       }
  end

  context "new build status" do
    subject { updater.new_build_status }
    before do
      create :job, build: b, status: 3, number: 1
      create :job, build: b, status: 4, number: 2
      create :job, build: b, status: 5, number: 3
    end
    it { should eq 5 }
  end

  context "update_build?" do

    context "when all jobs exists" do
      subject { updater.update_build? }
      before do
        b.update_attribute :jobs_count, 2
        create :job, build: b, status: 3, number: 1
        create :job, build: b, status: 3, number: 2
      end
      it { should be_true }
    end

    context "when job missing" do
      subject { updater.update_build? }
      before do
        b.update_attribute :jobs_count, 2
        create :job, build: b, status: 3, number: 1
      end
      it { should be_false }
    end

  end

  context "perform" do

    context "publish job" do
      subject { updater.perform }
      before do
        mock(job).publish { true }
      end
      it { should be }
    end

    context "publish build and project" do
      subject { updater.perform }

      context "when build updated" do
        before do
          mock(updater).update_build? { true }
          mock(b).publish(serializer: :build_status) { true }
          mock(b.project).publish { true }
        end
        it { should be }
      end
    end

    context "update job status" do
      let(:tm)                 { Time.now }
      let(:message_attributes) { {
        status: status,
        tm:     tm.to_i,
      } }
      subject {
        updater.perform
        job
      }

      context "when status 2 (STARTED)" do
        let(:status) { 2 }
        its(:status_name)      { should eq :started }
        its("started_at.to_i") { should eq tm.to_i }
      end

      context "when status 3 (FINISHED)" do
        let(:status) { 3 }
        before { job.start }
        its(:status_name)       { should eq :finished }
        its("finished_at.to_i") { should eq tm.to_i }
      end

      context "when status 4 (FAILED)" do
        let(:status) { 4 }
        before { job.start }
        its(:status_name)       { should eq :failed }
        its("finished_at.to_i") { should eq tm.to_i }
      end

      context "when status 4 (ERRORED)" do
        let(:status) { 5 }
        before { job.start }
        its(:status_name)       { should eq :errored }
        its("finished_at.to_i") { should eq tm.to_i }
      end
    end

    context "update build status" do
      let(:tm)                 { Time.now }
      let(:message_attributes) { {
        tm: tm.to_i,
      } }
      subject {
        updater.perform
        b
      }
      before do
        mock(updater).update_build? { true }
        mock(updater).new_build_status { status }
      end

      context "when new status 2 (STARTED)" do
        let(:status) { 2 }
        it "cannot touch build" do
          expect{ subject }.to_not change(b, :status)
        end
      end

      context "when new status 3 (FINISHED)" do
        let(:status) { 3 }
        before { b.start }
        its(:status_name)       { should eq :finished }
        its("finished_at.to_i") { should eq tm.to_i   }
      end

      context "when new status 4 (FAILED)" do
        let(:status) { 4 }
        before { b.start }
        its(:status_name)       { should eq :failed }
        its("finished_at.to_i") { should eq tm.to_i }
      end

      context "when new status 4 (ERRORED)" do
        let(:status) { 5 }
        before { b.start }
        its(:status_name)       { should eq :errored }
        its("finished_at.to_i") { should eq tm.to_i }
      end
    end

  end

end
