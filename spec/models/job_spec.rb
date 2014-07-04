require 'spec_helper'
require 'ostruct'

describe Job do
  let(:job) { Job.new }

  it_should_behave_like "AppendLogMessage" do
    let(:job)        { create :job }
    let(:collection) { job.logs }
  end

  context "#to_builder_source" do
    let(:job) { create :job }
    subject { job.to_builder_source }
    it { should be }
  end

  context "#to_script_builder" do
    let(:job) { create :job }
    subject { job.to_script_builder }
    it { should be }
  end

  context "#to_perform_job_message" do
    let(:job) { create :job }
    subject { job.to_perform_job_message }
    it { should be }

    it "should be create PerformJob" do
      expect(subject).to be
    end

    it "should assign image" do
      job.update!(source: ({ "image" => %w{ one } }).to_yaml)
      expect(subject.image).to eq 'one'
    end

    it "should assign timeouts" do
      job.update!(source: ({ "vexor" => { "timeout" => "10", "read_timeout" => "20" } }).to_yaml)
      expect(subject.job_timeout).to eq 10
      expect(subject.job_read_timeout).to eq 20
    end
  end

  context "#publish_perform_job_message" do
    let(:job) { create :job }
    subject { job.publish_perform_job_message }

    it "should be" do
      expect {
        subject
      }.to change(JobsConsumer.messages, :count).by(1)
    end
  end

  it "should publish(:created) after create" do
    b = create :build
    expect{
      create :job, build: b
    }.to change(SockdNotifyConsumer.messages, :count).by(1)
    msg = SockdNotifyConsumer.messages.last
    expect(msg[:channel]).to eq 'company/00000000-0000-0000-0000-000000000000'
    expect(msg[:_event]).to eq "job:created"
  end

  context "#create_job_history!" do
    let(:now) { Time.current }
    let(:b)   { create :build }
    it "should create job_history instance if job finished" do
      jobs = ["passed","failed","errored"].map do |n|
        create(:job, build: b, number: n, status: n, started_at: now - 180.seconds, finished_at: now - 90.seconds)
      end

      jobs.each do |job|
        expect{ job.create_job_history! }.to change(JobHistory, :count).by(1)

        job_history = JobHistory.find_by!(job_number: job.number)
        expect(job_history.company).to      eq(job.company)
        expect(job_history.build_number).to eq(job.build.number)
        expect(job_history.job_number).to   eq(job.number)
        expect(job_history.duration).to     eq(90)
      end
    end

    it "cannot create job history instance unless job finished" do
      jobs = [0,6].map do |n|
        create(:job, build: b, number: n, status: n, started_at: now - 180.seconds, finished_at: now - 90.seconds)
      end
      jobs.each do |job|
        expect{ job.create_job_history! }.to_not change(JobHistory, :count)
      end
    end
  end

  context "(state machine)" do
    context "after transition to started" do
      let!(:job) { create :job, status: status }
      let(:status) { "status" }
      subject { job.start }

      it "should delivery messages to SockdNotifyConsumer" do
        expect{
          subject
        }.to change(SockdNotifyConsumer.messages, :count).by(1)
      end
    end

    context "after transition to cancelled" do
      let!(:job) { create :job, status: status }
      let(:status) { "initialized" }
      subject { job.cancel }

      it "should delivery messages to SockdNotifyConsumer" do
        expect{
          subject
        }.to change(SockdNotifyConsumer.messages, :count).by(1)
      end
    end

    context "after transition to passed" do
      let!(:job) { create :job, status: status }
      let(:status) { "started" }
      subject { job.pass }

      it "should delivery messages to SockdNotifyConsumer" do
        expect{
          subject
        }.to change(SockdNotifyConsumer.messages, :count).by(1)
      end
    end

    context "after transition to failed" do
      let!(:job) { create :job, status: status }
      let(:status) { "started" }
      subject { job.decline }

      it "should delivery messages to SockdNotifyConsumer" do
        expect{
          subject
        }.to change(SockdNotifyConsumer.messages, :count).by(1)
      end
    end

    context "after transition to errored" do
      let!(:job) { create :job, status: status }
      let(:status) { "started" }
      subject { job.error }

      it "should delivery messages to SockdNotifyConsumer" do
        expect{
          subject
        }.to change(SockdNotifyConsumer.messages, :count).by(1)
      end
    end
  end

  context "#finished?" do
    subject { job.finished? }
    ["initialized", "started"].each do |s|
      context "when status is #{s}" do
        before { job.status = s }
        it { should be(false) }
      end
    end

    ["passed", "failed", "errored"].each do |s|
      context "when status is #{s}" do
        before { job.status = s }
        it { should be(true) }
      end
    end
  end

  context "#restart!" do
    let(:job) { create :job }
    subject   { job.restart.try(:reload) }

    context "when job is finished" do
      before do
        job.update! status: "passed"
      end

      it { should eq job }

      its(:started_at)  { should be_nil }
      its(:finished_at) { should be_nil }
      its(:status_name) { should eq :initialized }

      it "should delivery message to SockdNotifyConsumer" do
        expect{
          subject
        }.to change(SockdNotifyConsumer.messages, :count).by(1)
      end
    end
  end

  context ".status" do
    subject { described_class.status }

    before do
      b = create :build
      num = 0
      3.times { create :job, status: "initialized", build: b, number: num += 1 }
      5.times { create :job, status: "started", build: b, number: num += 1 }
      1.times { create :job, status: "passed", build: b, number: num += 1 }
    end

    it { should eq(initialized: 3, started: 5) }
  end

end

# == Schema Information
#
# Table name: jobs
#
#  number      :integer          not null
#  status      :integer          not null
#  matrix      :hstore
#  started_at  :datetime
#  finished_at :datetime
#  created_at  :datetime
#  updated_at  :datetime
#  source      :text             not null
#  kind        :string(255)      not null
#  build_id    :uuid             not null
#  id          :uuid             not null, primary key
#

