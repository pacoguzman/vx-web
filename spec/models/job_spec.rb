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

    context "with image" do
      before do
        job.update!(source: ({ "image" => %w{ one } }).to_yaml)
      end
      its(:image) { should eq 'one' }
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
    }.to change(ServerSideEventsConsumer.messages, :count).by(1)
    msg = ServerSideEventsConsumer.messages.last
    expect(msg[:channel]).to eq 'jobs'
    expect(msg[:event]).to eq :created
  end

  context "(state machine)" do
    let!(:job) { create :job, status: status }

    context "after transition to started" do
      let(:status) { "initialized" }
      subject { job.start }

      it "should delivery messages to ServerSideEventsConsumer" do
        expect{
          subject
        }.to change(ServerSideEventsConsumer.messages, :count).by(1)
      end
    end

    context "after transition to passed" do
      let(:status) { "started" }
      subject { job.pass }

      it "should delivery messages to ServerSideEventsConsumer" do
        expect{
          subject
        }.to change(ServerSideEventsConsumer.messages, :count).by(1)
      end
    end

    context "after transition to failed" do
      let(:status) { "started" }
      subject { job.decline }

      it "should delivery messages to ServerSideEventsConsumer" do
        expect{
          subject
        }.to change(ServerSideEventsConsumer.messages, :count).by(1)
      end
    end

    context "after transition to errored" do
      let(:status) { "started" }
      subject { job.error }

      it "should delivery messages to ServerSideEventsConsumer" do
        expect{
          subject
        }.to change(ServerSideEventsConsumer.messages, :count).by(1)
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

      it "should delivery message to ServerSideEventsConsumer" do
        expect{
          subject
        }.to change(ServerSideEventsConsumer.messages, :count).by(1)
      end

      it "should delivery message to JobsConsumer" do
        expect{
          subject
        }.to change(JobsConsumer.messages, :count).by(1)
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
#  id          :integer          not null, primary key
#  build_id    :integer          not null
#  number      :integer          not null
#  status      :integer          not null
#  matrix      :hstore
#  started_at  :datetime
#  finished_at :datetime
#  created_at  :datetime
#  updated_at  :datetime
#  source      :text             not null
#  kind        :string(255)
#

