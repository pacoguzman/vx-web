require 'spec_helper'

describe Build do
  let(:build)   { Build.new       }
  let(:project) { create :project }
  subject       { build           }

  context "before creation" do
    subject { ->{ build.save! } }
    before { build.project = project }

    context "assign number" do

      it "should be 1 when no other builds" do
        expect(subject).to change(build, :number).to(1)
      end

      it "should increment when any other builds exist" do
        create :build, project: project
        expect(subject).to change(build, :number).to(2)
      end
    end

    context "assign sha" do
      it "by default should be 'HEAD'" do
        expect(subject).to change(build, :sha).to("HEAD")
      end

      it "when exists dont touch sha" do
        build.sha = '1234'
        expect(subject).to_not change(build, :sha)
      end
    end

    context "assign branch" do
      it "by default should be 'master'" do
        expect(subject).to change(build, :branch).to("master")
      end

      it "when exists dont touch branch" do
        build.branch = '1234'
        expect(subject).to_not change(build, :branch)
      end
    end
  end

  it "should publish(:created) after create" do
    expect{
      create :build
    }.to change(WsPublishConsumer.messages, :count).by(1)
    msg = WsPublishConsumer.messages.last
    expect(msg[:channel]).to eq 'builds'
    expect(msg[:event]).to eq :created
  end

  context "(messages)" do
    let(:build)   { create :build }

    context "#to_perform_build_message" do
      let(:travis)  { 'travis' }
      let(:project) { build.project }
      subject { build.to_perform_build_message travis }

      context "should create PerformBuild message with" do
        its(:id)         { should eq build.id }
        its(:name)       { should eq project.name }
        its(:src)        { should eq project.clone_url }
        its(:sha)        { should eq build.sha }
        its(:deploy_key) { should eq project.deploy_key }
        its(:travis)     { should eq travis }
        its(:branch)     { should eq build.branch }
      end
    end

    context "#delivery_to_fetcher" do
      it "should be success" do
        expect{
          build.delivery_to_fetcher
        }.to change(FetchBuildConsumer.messages, :count).by(1)
      end
    end

    context "#delivery_to_notifier" do
      it "should be success" do
        expect{
          build.delivery_to_notifier("started")
        }.to change(BuildNotifyConsumer.messages, :count).by(1)
      end
    end

    context "#delivery_perform_build_message" do
      it "should be success" do
        expect{
          build.delivery_perform_build_message 'travis'
        }.to change(BuildsConsumer.messages, :count).by(1)
      end
    end
  end

  context "find_or_create_job_by_status_message" do
    let(:msg) { Evrone::CI::Message::JobStatus.test_message }
    subject { build.find_or_create_job_by_status_message msg }

    context "when job does not exists" do
      it "should create job" do
        expect {
          subject
        }.to change(build.jobs, :size).by(1)
      end
    end
  end

  context "duration" do
    subject { build.duration }

    it "should be" do
      Timecop.freeze(Time.local(1990)) do
        build.started_at = 23.minutes.ago
        build.finished_at = 1.minute.ago
      end
      expect(subject).to eq 1320.0
    end

    context "without started_at" do
      before { build.finished_at = 1.day.ago }
      it { should be_nil }
    end

    context "without finished_at" do
      before { build.started_at = 1.day.ago }
      it { should be_nil }
    end

  end

  context "(state machine)" do
    let!(:b) { create :build, status: status }

    context "after transition to started" do
      let(:status) { 0 }
      subject { b.start }

      it "should delivery message to notifier" do
        mock(b).delivery_to_notifier("started") { true }
        expect(subject).to be
      end

      it "should delivery messages to WsPublishConsumer" do
        expect{
          subject
        }.to change(WsPublishConsumer.messages, :count).by(2)
      end
    end

    context "after transition to finished" do
      let(:status) { 2 }
      subject { b.finish }

      it "should delivery message to notifier" do
        mock(b).delivery_to_notifier("finished") { true }
        expect(subject).to be
      end

      it "should delivery messages to WsPublishConsumer" do
        expect{
          subject
        }.to change(WsPublishConsumer.messages, :count).by(2)
      end
    end

    context "after transition to failed" do
      let(:status) { 2 }
      subject { b.decline }

      it "should delivery message to notifier" do
        mock(b).delivery_to_notifier("failed") { true }
        expect(subject).to be
      end

      it "should delivery messages to WsPublishConsumer" do
        expect{
          subject
        }.to change(WsPublishConsumer.messages, :count).by(2)
      end
    end

    context "after transition to errored" do
      let(:status) { 2 }
      subject { b.error }

      it "should delivery message to notifier" do
        mock(b).delivery_to_notifier("errored") { true }
        expect(subject).to be
      end
    end
  end

  context "#prev_completed_build_in_branch" do
    let(:build) { create :build, number: 2, branch: 'foo', status: 3 }
    subject { build.prev_completed_build_in_branch }

    context "when build exists" do
      let!(:prev_build) { create :build, number: 1, branch: 'foo', project: build.project, status: 3 }
      let!(:next_build) { create :build, number: 3, branch: 'foo', project: build.project, status: 3 }

      it { should eq prev_build }
    end

    context "when build is not exists" do
      let!(:p1) { create :build, number: 1, branch: 'bar', project_id: build.project_id, status: 3 }
      let!(:p1) { create :build, number: 1, branch: 'foo', project_id: build.project_id + 1, status: 3 }
      let!(:p1) { create :build, number: 1, branch: 'foo', project_id: build.project_id, status: 2 }

      it { should be_nil }
    end
  end

  context "#completed?" do
    subject { build.completed? }
    [0,2].each do |s|
      context "when status is #{s}" do
        before { build.status = s }
        it { should be_false }
      end
    end

    [3,4,5].each do |s|
      context "when status is #{s}" do
        before { build.status = s }
        it { should be_true }
      end
    end
  end

  context "#status_has_changed?" do
    let(:prev) { Build.new status: prev_status }
    subject { build.status_has_changed? }

    before do
      stub(build).prev_completed_build_in_branch { prev }
    end

    context "when status is different" do
      let(:prev_status) { 3 }

      before do
        build.status = 4
      end

      it { should be_true }
    end

    context "when status is same" do
      let(:prev_status) { 3 }

      before do
        build.status = 3
      end

      it { should be_false }
    end

    context "when prev build is nil" do
      let(:prev) { nil }

      before do
        build.status = 3
      end

      it { should be_false }
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
#  message         :string(255)
#  status          :integer          default(0), not null
#  started_at      :datetime
#  finished_at     :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  author_email    :string(255)
#  jobs_count      :integer          default(0), not null
#  http_url        :string(255)
#  branch_label    :string(255)
#

