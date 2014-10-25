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
        other_build = create(:build, project: project)
        expect{ b.save! }.to change{ b.number }.to(other_build.number + 1)
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
    project = create :project, company: create(:company)
    expect{
      create :build, project: project
    }.to change(SockdNotifyConsumer.messages, :count).by(2)
    msg = SockdNotifyConsumer.messages.select{ |m| m[:_event] == 'build:created' }.first
    expect(msg.keys).to eq [:channel, :event, :_event, :payload]
    expect(msg[:channel]).to eq 'company/00000000-0000-0000-0000-000000000000'
    expect(msg[:payload]).to_not be_empty
  end

  it "should publish updated" do
    b.save!
    expect{
      b.publish_updated
    }.to change(SockdNotifyConsumer.messages, :count).by(2)
    msg = SockdNotifyConsumer.messages.select{ |m| m[:_event] == 'build:updated' }.first
    expect(msg.keys).to eq [:channel, :event, :_event, :payload]
    expect(msg[:channel]).to eq 'company/00000000-0000-0000-0000-000000000000'
    expect(msg[:payload]).to_not be_empty
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
    let(:job) { create :job, build: b }
    subject { b.to_builder_task job }
    it { should be }
    its(:name)                 { should eq "ci-worker-test-repo" }
    its(:src)                  { should eq 'git@example.com' }
    its(:sha)                  { should eq '91405d6c13b48904694f67f7abc29ef08a825728' }
    its(:deploy_key)           { should be }
    its(:branch)               { should eq 'MyString' }
    its(:cache_url_prefix)     { should eq "http://test.host/f/cached_files/#{b.project.token}" }
    its(:build_id)             { should eq b.id }
    its(:job_id)               { should eq job.id }
    its(:project_host)         { should eq 'example.com' }
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
      let(:status) { "initialized" }
      subject { b.start! } # Bang so the last build has its status persisted when search for the last_build_id

      it "should delivery message to BuildNotifyConsumer" do
        expect{
          subject
        }.to change(BuildNotifyConsumer.messages, :count).by(1)
        msg = BuildNotifyConsumer.messages.last
        expect(msg["status"]).to eq "started"
      end

      it "should delivery messages to SockdNotifyConsumer" do
        expect{
          subject
        }.to change(SockdNotifyConsumer.messages, :count).by(2)
      end
    end

    context "after transition to deployed" do
      let(:status) { "started" }
      subject { b.deploy }

      it "should delivery message to BuildNotifyConsumer" do
        expect{
          subject
        }.to change(BuildNotifyConsumer.messages, :count).by(1)
        msg = BuildNotifyConsumer.messages.last
        expect(msg["status"]).to eq "deploying"
      end

      it "should delivery messages to SockdNotifyConsumer" do
        expect{
          subject
        }.to change(SockdNotifyConsumer.messages, :count).by(2)
      end
    end

    context "after transition to passed" do
      let(:status) { "started" }
      subject { b.pass }

      it "should delivery message to BuildNotifyConsumer" do
        expect{
          subject
        }.to change(BuildNotifyConsumer.messages, :count).by(1)
        msg = BuildNotifyConsumer.messages.last
        expect(msg["status"]).to eq "passed"
      end

      it "should delivery messages to SockdNotifyConsumer" do
        expect{
          subject
        }.to change(SockdNotifyConsumer.messages, :count).by(2)
      end
    end

    context "after transition to failed" do
      let(:status) { "started" }
      subject { b.decline }

      it "should delivery message to BuildNotifyConsumer" do
        expect{
          subject
        }.to change(BuildNotifyConsumer.messages, :count).by(1)
        msg = BuildNotifyConsumer.messages.last
        expect(msg["status"]).to eq "failed"
      end

      it "should delivery messages to SockdNotifyConsumer" do
        expect{
          subject
        }.to change(SockdNotifyConsumer.messages, :count).by(2)
      end
    end

    context "after transition to errored" do
      let(:status) { "started" }
      subject { b.error }

      it "should delivery message to BuildNotifyConsumer" do
        expect{
          subject
        }.to change(BuildNotifyConsumer.messages, :count).by(1)
        msg = BuildNotifyConsumer.messages.last
        expect(msg["status"]).to eq "errored"
      end

      it "should delivery messages to SockdNotifyConsumer" do
        expect{
          subject
        }.to change(SockdNotifyConsumer.messages, :count).by(2)
      end
    end
  end

  context "#prev_finished_build_in_branch" do
    let(:b) { create :build, number: 2, branch: 'foo', status: "passed" }
    subject { b.prev_finished_build_in_branch }

    context "when build exists" do
      let!(:prev_build) { create :build, number: 1, branch: 'foo', project: b.project, status: "passed" }
      let!(:next_build) { create :build, number: 3, branch: 'foo', project: b.project, status: "passed" }

      it { should eq prev_build }
    end

    context "when build is not exists" do
      let!(:p1) { create :build, number: 1, branch: 'bar', project_id: b.project_id, status: "passed" }
      let!(:p1) { create :build, number: 1, branch: 'foo', project_id: b.project_id + 1, status: "passed" }
      let!(:p1) { create :build, number: 1, branch: 'foo', project_id: b.project_id, status: "started" }

      it { should be_nil }
    end
  end

  context "#finished?" do
    subject { b.finished? }
    ["initialized", "started"].each do |s|
      context "when status is #{s}" do
        before { b.status = s }
        it { should be(false) }
      end
    end

    ["passed", "failed", "errored"].each do |s|
      context "when status is #{s}" do
        before { b.status = s }
        it { should be(true) }
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
      let(:prev_status) { "passed" }

      before do
        b.status = "failed"
      end

      it { should be(true) }
    end

    context "when status is same" do
      let(:prev_status) { "passed" }

      before do
        b.status = "passed"
      end

      it { should be(false) }
    end

    context "when prev build is nil" do
      let(:prev) { nil }

      before do
        b.status = "passed"
      end

      it { should be(true) }
    end
  end

  context "#human_status_name" do
    let(:prev) { create :build, status: prev_status, project: project }

    subject { b.human_status_name }

    ["initialized", "started", "failed", "errored"].each do |s|
      context "when status is #{s}" do
        before { b.status = s }
        it { should eq b.human_status_name.to_s.capitalize }
      end
    end

    context "when status is 'started'" do
      before do
        b.status = "passed"
        stub(b).prev_finished_build_in_branch { prev }
      end

      context "and previous build is not passed" do
        let(:prev_status) { "failed" }
        it { should eq 'Fixed' }
      end

      context "and previous build is not exists" do
        let(:prev) { nil }
        it { should eq 'Passed' }
      end

      context "and previous build is passed" do
        let(:prev_status) { "passed" }
        it { should eq 'Passed' }
      end
    end

    context "when status is 'failed'" do
      before do
        b.status = "failed"
        stub(b).prev_finished_build_in_branch { prev }
      end

      context "and previous build is failed" do
        let(:prev_status) { "failed" }
        it { should eq 'Still Failing' }
      end

      context "and previous build is not failed" do
        let(:prev_status) { "passed" }
        it { should eq 'Failed' }
      end
    end

    context "when status is 'errored'" do
      before do
        b.status = "errored"
        stub(b).prev_finished_build_in_branch { prev }
      end

      context "and previous build is errored" do
        let(:prev_status) { "errored" }
        it { should eq 'Still Broken' }
      end

      context "and previous build is not errored" do
        let(:prev_status) { "passed" }
        it { should eq 'Broken' }
      end
    end
  end

  context "#notify?" do
    let(:b) { build :build }
    subject { b.notify? }
    before do
      b.status = "started"
    end

    context "when status failed" do
      before do
        b.decline
      end
      it { should be(true) }
    end

    context "when status errored" do
      before do
        b.error
      end
      it { should be(true) }
    end

    context "when status passed" do
      before do
        b.pass
      end
      it { should be(true) }
    end
  end

  context "#restart" do
    let(:b)    { create :build }
    let(:job1) { create :job, build: b, number: 1 }
    let(:job2) { create :job, :deploy, build: b, number: 2 }
    subject    { b.restart.try(:reload) }

    context "when build is finished" do
      before do
        job1.update! status: "passed"
        job2.update! status: "passed"
        b.update! status: "passed"
      end

      it { should eq b }

      its(:started_at)  { should be_nil }
      its(:finished_at) { should be_nil }
      its(:status_name) { should eq :initialized }

      it "should delivery messages to SockdNotifyConsumer" do
        expect{
          subject
        }.to change(SockdNotifyConsumer.messages, :count).by(3)
        build_m = SockdNotifyConsumer.messages.pop
        job2_m  = SockdNotifyConsumer.messages.pop

        expect(job2_m[:channel]).to eq "company/00000000-0000-0000-0000-000000000000"
        expect(job2_m[:_event]).to eq "job:updated"
        expect(job2_m[:payload][:id]).to eq job2.id

        expect(job2_m[:channel]).to eq "company/00000000-0000-0000-0000-000000000000"
        expect(build_m[:_event]).to eq "build:updated"
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

  context "to_build_configuration" do
    subject { b.to_build_configuration }
    before do
      b.source = {"script" => "/bin/true"}.to_yaml
    end
    it { should be }
    its(:attributes) { should_not be_empty }
    its(:script)     { should eq ["/bin/true"] }
  end

  context "to_matrix.build" do
    subject { b.to_matrix.build }
    before do
      b.source = {"rvm" => %w{ 1.9 2.0 }}.to_yaml
    end
    it { should be }
    it { subject.size.should eq(2) }
  end

  context "to_deploy.build" do
    subject { b.to_deploy.build }
    before do
      b.source = {"deploy" => { "shell" => "/bin/true", "branch" => "master" } }.to_yaml
    end
    it { should be }
    it { subject.size.should eq(1) }

    context "when branch is not matched" do
      before do
        b.branch = 'production'
      end
      it { should be_empty }
    end
  end

  context "publish_perform_job_messages" do
    subject { job.build.publish_perform_job_messages }

    context "regular" do
      let(:job) { create :job }

      it "should publish messages" do
        expect {
          subject
        }.to change(JobsConsumer.messages, :count).by(1)
      end
    end

    context "deploy" do
      let(:job) { create :job, :deploy }

      it "should publish messages" do
        expect {
          subject
        }.to change(JobsConsumer.messages, :count).by(1)
      end
    end
  end

  context "subscribe_author" do
    let(:author)  { 'me@example.com' }
    let!(:b)      { create :build, author_email: author }
    let!(:user)   { create :user, email: author }
    subject { b.subscribe_author }

    it "should be" do
      expect {
        subject
      }.to change(user.project_subscriptions, :count).by(1)
    end
  end

  context "create_regular_jobs" do
    let(:b) { create :build }
    subject { b.create_regular_jobs }

    before do
      b.source = {"rvm" => %w{ 1.9 2.0 }}.to_yaml
    end

    it { should be }

    context "created jobs" do
      subject { b.jobs }
      before do
        b.create_regular_jobs
      end
      it { subject.size.should eq(2) }

      it "should have true matrices" do
        expect(subject.map(&:matrix)).to eq [{"rvm"=>"1.9"}, {"rvm"=>"2.0"}]
      end

      it "should have true numbers" do
        expect(subject.map(&:number)).to eq [1,2]
      end

      it "should have true sources" do
        expect(subject.map{|i| YAML.load(i.source)["rvm"] }).to eq [["1.9"], ["2.0"]]
      end

      it "should have true kind" do
        expect(subject.map(&:kind)).to eq %w{ regular regular }
      end
    end
  end

  context "create_deploy_jobs" do
    let(:b) { create :build }
    subject { b.create_deploy_jobs }

    before do
      b.source = {"deploy" => { "shell" => "/bin/true" }}.to_yaml
    end

    it { should be }

    context "created jobs" do
      subject { b.jobs }
      before do
        b.create_deploy_jobs
      end
      it { subject.size.should eq(1) }

      it "should have matrixes" do
        expect(subject.map(&:matrix)).to eq [{}]
      end

      it "should have true numbers" do
        expect(subject.map(&:number)).to eq [1]
      end

      it "should have true sources" do
        expect(subject.map{|i| YAML.load(i.source)["deploy_modules"] }).to eq [[{"shell"=>["/bin/true"]}]]
      end

      it "should have true kind" do
        expect(subject.map(&:kind)).to eq %w{ deploy }
      end
    end
  end

  context "rebuild" do
    let(:b) do
      create :build, status: 'passed', source: { "rvm" => %w{ 2.0 2.1 }, "deploy" => { "shell" => "true" } }.to_yaml
    end

    it "should allow to rebuild only finished builds" do
      b.status = 'started'
      expect(b.rebuild).to be_nil
    end

    it "should create a new build with same attributes" do
      new_build = b.rebuild
      expect(new_build).to be_persisted
      expect(new_build.status).to eq 'initialized'
      expect(new_build.number).to eq(b.number + 1)
      %i[
        pull_request_id sha branch author message author_email
        http_url branch_label source project_id
      ].each do |attr|
        expect(new_build.public_send(attr)).to eq b.public_send(attr)
      end
    end

    it "should create new jobs for new build" do
      new_build = b.rebuild

      expect(new_build.jobs.regular.size).to eq(2)
      expect(new_build.jobs.deploy.size).to eq(1)
      expect(new_build.jobs.map(&:status).uniq).to eq ['initialized']
    end

    it "should publish PerformJob messages" do
      new_build = nil
      expect {
        new_build = b.rebuild
      }.to change(JobsConsumer.messages, :count).from(0).to(2)
      expect(JobsConsumer.messages.map(&:job_id).sort).to eq new_build.jobs.regular.map(&:id).sort
    end

    it "should notify sockd about new build" do
      b
      Vx::Consumer::Testing.clear
      new_build = nil
      expect {
        new_build = b.rebuild
      }.to change(SockdNotifyConsumer.messages, :count).from(0).to(5)
      msgs = SockdNotifyConsumer.messages
      expect(msgs.map{|i| i[:_event] }.sort).to eq ["build:created", "job:created", "job:created", "job:created", "project:updated"]
    end
  end

end

# == Schema Information
#
# Table name: builds
#
#  number          :integer          not null
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
#  token           :string(255)      not null
#  project_id      :uuid             not null
#  id              :uuid             not null, primary key
#
