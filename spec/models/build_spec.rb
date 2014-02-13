require 'spec_helper'

describe Build do
  let(:b)       { build :build, branch: nil, sha: nil, number: nil }
  let(:project) { b.project }
  subject       { b }

  context "before creation" do
    subject { ->{ b.save! } }

    context "assign number" do

      it "should be 1 when no other builds" do
        expect(subject).to change(b, :number).to(1)
      end

      it "should increment when any other builds exist" do
        create :build, project: project
        expect(subject).to change(b, :number).to(2)
      end
    end

    context "assign sha" do
      it "by default should be 'HEAD'" do
        expect(subject).to change(b, :sha).to("HEAD")
      end

      it "when exists dont touch sha" do
        b.sha = '1234'
        expect(subject).to_not change(b, :sha)
      end
    end

    context "assign branch" do
      it "by default should be 'master'" do
        expect(subject).to change(b, :branch).to("master")
      end

      it "when exists dont touch branch" do
        b.branch = '1234'
        expect(subject).to_not change(b, :branch)
      end
    end

    it "should assign token" do
      expect(subject).to change(b, :token).from(nil)
    end
  end

  it "should publish(:created) after create" do
    expect{
      create :build
    }.to change(ServerSideEventsConsumer.messages, :count).by(1)
    msg = ServerSideEventsConsumer.messages.last
    expect(msg[:channel]).to eq 'builds'
    expect(msg[:event]).to eq :created
  end

  context "(messages)" do
    let(:b) { create :build, pull_request_id: 1 }

    context "#delivery_to_notifier" do
      it "should be success" do
        expect{
          b.delivery_to_notifier
        }.to change(BuildNotifyConsumer.messages, :count).by(1)
        msg = BuildNotifyConsumer.messages.last
        expect(msg).to eq b.attributes
      end
    end
  end

  context "to_builder_task" do
    let(:b) { create :build }
    subject { b.to_builder_task }
    it { should be }
    its(:name)             { should eq "ci-worker-test-repo" }
    its(:src)              { should eq 'MyString' }
    its(:sha)              { should eq 'MyString' }
    its(:deploy_key)       { should be }
    its(:branch)           { should eq 'MyString' }
    its(:cache_url_prefix) { should be }
  end

  context "duration" do
    subject { b.duration }

    it "should be" do
      Timecop.freeze(Time.local(1990)) do
        b.started_at = 23.minutes.ago
        b.finished_at = 1.minute.ago
      end
      expect(subject).to eq 1320.0
    end

    context "without started_at" do
      before { b.finished_at = 1.day.ago }
      it { should be_nil }
    end

    context "without finished_at" do
      before { b.started_at = 1.day.ago }
      it { should be_nil }
    end
  end

  context "(state machine)" do
    let!(:b) { create :build, status: status }

    context "after transition to started" do
      let(:status) { 0 }
      subject { b.start }

      it "should delivery message to BuildNotifyConsumer" do
        expect{
          subject
        }.to change(BuildNotifyConsumer.messages, :count).by(1)
        msg = BuildNotifyConsumer.messages.last
        expect(msg["status"]).to eq 2
      end

      it "should delivery messages to ServerSideEventsConsumer" do
        expect{
          subject
        }.to change(ServerSideEventsConsumer.messages, :count).by(2)
      end

      it "should update last_build on project" do
        expect{
          subject
        }.to change{ b.project.reload.last_build_id }.to(b.id)
      end
    end

    context "after transition to passed" do
      let(:status) { 2 }
      subject { b.pass }

      it "should delivery message to BuildNotifyConsumer" do
        expect{
          subject
        }.to change(BuildNotifyConsumer.messages, :count).by(1)
        msg = BuildNotifyConsumer.messages.last
        expect(msg["status"]).to eq 3
      end

      it "should delivery messages to ServerSideEventsConsumer" do
        expect{
          subject
        }.to change(ServerSideEventsConsumer.messages, :count).by(2)
      end
    end

    context "after transition to failed" do
      let(:status) { 2 }
      subject { b.decline }

      it "should delivery message to BuildNotifyConsumer" do
        expect{
          subject
        }.to change(BuildNotifyConsumer.messages, :count).by(1)
        msg = BuildNotifyConsumer.messages.last
        expect(msg["status"]).to eq 4
      end

      it "should delivery messages to ServerSideEventsConsumer" do
        expect{
          subject
        }.to change(ServerSideEventsConsumer.messages, :count).by(2)
      end
    end

    context "after transition to errored" do
      let(:status) { 2 }
      subject { b.error }

      it "should delivery message to BuildNotifyConsumer" do
        expect{
          subject
        }.to change(BuildNotifyConsumer.messages, :count).by(1)
        msg = BuildNotifyConsumer.messages.last
        expect(msg["status"]).to eq 5
      end

      it "should delivery messages to ServerSideEventsConsumer" do
        expect{
          subject
        }.to change(ServerSideEventsConsumer.messages, :count).by(2)
      end
    end
  end

  context "#prev_finished_build_in_branch" do
    let(:b) { create :build, number: 2, branch: 'foo', status: 3 }
    subject { b.prev_finished_build_in_branch }

    context "when build exists" do
      let!(:prev_build) { create :build, number: 1, branch: 'foo', project: b.project, status: 3 }
      let!(:next_build) { create :build, number: 3, branch: 'foo', project: b.project, status: 3 }

      it { should eq prev_build }
    end

    context "when build is not exists" do
      let!(:p1) { create :build, number: 1, branch: 'bar', project_id: b.project_id, status: 3 }
      let!(:p1) { create :build, number: 1, branch: 'foo', project_id: b.project_id + 1, status: 3 }
      let!(:p1) { create :build, number: 1, branch: 'foo', project_id: b.project_id, status: 2 }

      it { should be_nil }
    end
  end

  context "#finished?" do
    subject { b.finished? }
    [0,2].each do |s|
      context "when status is #{s}" do
        before { b.status = s }
        it { should be_false }
      end
    end

    [3,4,5].each do |s|
      context "when status is #{s}" do
        before { b.status = s }
        it { should be_true }
      end
    end
  end

  context "#status_has_changed?" do
    let(:prev) { Build.new status: prev_status }
    subject { b.status_has_changed? }

    before do
      stub(b).prev_finished_build_in_branch { prev }
    end

    context "when status is different" do
      let(:prev_status) { 3 }

      before do
        b.status = 4
      end

      it { should be_true }
    end

    context "when status is same" do
      let(:prev_status) { 3 }

      before do
        b.status = 3
      end

      it { should be_false }
    end

    context "when prev build is nil" do
      let(:prev) { nil }

      before do
        b.status = 3
      end

      it { should be_true }
    end
  end

  context "#human_status_name" do
    let(:prev) { create :build, status: prev_status, project: project }

    subject { b.human_status_name }

    [0,2,4,5].each do |s|
      context "when status is #{s}" do
        before { b.status = s }
        it { should eq b.human_status_name.to_s.capitalize }
      end
    end

    context "when status is 3" do
      before do
        b.status = 3
        stub(b).prev_finished_build_in_branch { prev }
      end

      context "and previous build is not passed" do
        let(:prev_status) { 4 }
        it { should eq 'Fixed' }
      end

      context "and previous build is not exists" do
        let(:prev) { nil }
        it { should eq 'Passed' }
      end

      context "and previous build is passed" do
        let(:prev_status) { 3 }
        it { should eq 'Passed' }
      end
    end

    context "when status is 4" do
      before do
        b.status = 4
        stub(b).prev_finished_build_in_branch { prev }
      end

      context "and previous build is failed" do
        let(:prev_status) { 4 }
        it { should eq 'Still Failing' }
      end

      context "and previous build is not failed" do
        let(:prev_status) { 3 }
        it { should eq 'Failed' }
      end
    end

    context "when status is 5" do
      before do
        b.status = 5
        stub(b).prev_finished_build_in_branch { prev }
      end

      context "and previous build is errored" do
        let(:prev_status) { 5 }
        it { should eq 'Still Broken' }
      end

      context "and previous build is not errored" do
        let(:prev_status) { 3 }
        it { should eq 'Broken' }
      end
    end
  end

  context "#notify?" do
    let(:b) { build :build }
    subject { b.notify? }
    before do
      b.status = 2
    end

    context "when status failed" do
      before do
        b.decline
      end
      it { should be_true }
    end

    context "when status errored" do
      before do
        b.error
      end
      it { should be_true }
    end

    context "when status passed" do
      before do
        b.pass
      end
      it { should be_true }
    end
  end

  context "#restart" do
    let(:job) { create :job, build: b }
    let(:b)   { create :build }
    subject   { b.restart.try(:reload) }

    context "when build is finished" do
      before do
        job.update! status: 3
        b.update! status: 3
      end

      it { should eq b }

      its(:started_at)  { should be_nil }
      its(:finished_at) { should be_nil }
      its(:status_name) { should eq :initialized }

      it "should delivery messages to ServerSideEventsConsumer" do
        expect{
          subject
        }.to change(ServerSideEventsConsumer.messages, :count).by(2)
        build_m = ServerSideEventsConsumer.messages.pop
        job_m   = ServerSideEventsConsumer.messages.pop

        expect(job_m[:channel]).to eq 'jobs'
        expect(job_m[:event]).to eq :updated
        expect(job_m[:payload][:id]).to eq job.id

        expect(build_m[:channel]).to eq 'builds'
        expect(build_m[:event]).to eq :updated
      end

      it "should delivery message to JobsConsumer" do
        expect {
          subject
        }.to change(JobsConsumer.messages, :count).to(1)
      end
    end
  end

  context "#source" do
    subject { b.source }
    before do
      b.source = { "script" => "true" }.to_yaml
    end

    it "should be" do
      expect(subject).to eq("script" => "true")
    end
  end
end

# == Schema Information
#
# Table name: builds
#
#  id              :integer          not null, primary key
#  number          :integer          not null
#  project_id      :integer          not null
#  sha             :string(255)      not null
#  branch          :string(255)      not null
#  pull_request_id :integer
#  author          :string(255)
#  message         :text
#  status          :integer          default(0), not null
#  started_at      :datetime
#  finished_at     :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  author_email    :string(255)
#  http_url        :string(255)
#  branch_label    :string(255)
#  source          :text             not null
#

