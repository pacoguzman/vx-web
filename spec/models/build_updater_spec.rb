require 'spec_helper'

describe BuildUpdater do
  let(:build_id) { 1 }
  let(:project)  { create :project }
  let(:build)    { Build.new  project:project }
  let(:message_attributes) { {} }
  let(:message)  {
    Evrone::CI::Message::BuildStatus.test_message(
      message_attributes.merge build_id: build_id
    )
  }
  let(:updater)  { BuildUpdater.new message }
  subject { updater }

  before do
    stub(Build).find_by(id: build_id) { build }
  end

  context "just created" do
    its(:message){ should eq message }
    its(:build){ should eq build }
  end

  context "perform" do
    subject { updater.perform }

    it { should be }

    it "should publish build" do
      mock(build).publish
      subject
    end

    context "update build status" do
      let(:tm)                 { Time.now }
      let(:message_attributes) { {
        status: status,
        tm:     tm.to_i,
      } }

      subject  {
        updater.perform
        build
      }

      context "when status 2 (STARTED)" do
        let(:status) { 2 }

        its(:status_name)      { should eq :started }
        its("started_at.to_i") { should eq tm.to_i  }
      end

      context "when status 3 (FINISHED)" do
        let(:status) { 3 }

        it "cannot touch build.status" do
          expect{ subject }.to_not change(build, :status)
        end
      end

      context "when status 4 (FAILED)" do
        let(:status) { 4 }
        before { build.start }

        its(:status_name)       { should eq :failed }
        its("finished_at.to_i") { should eq tm.to_i }
      end

      context "when status 5 (ERRORED)" do
        let(:status) { 5 }
        before { build.start }

        its(:status_name)       { should eq :errored }
        its("finished_at.to_i") { should eq tm.to_i }
      end
    end

    context "add jobs info to build" do
      let(:message_attributes) { {
        jobs_count: 99,
      } }

      subject { build }
      before  { updater.perform }

      its(:jobs_count) { should eq 99 }
    end

    context "add commit info to build" do
      subject { build }
      before  { updater.perform }

      context "when fields exist in message" do
        let(:message_attributes) { {
          commit_sha:           'sha',
          commit_author:        'author',
          commit_author_email:  "email",
          commit_message:       'message'
        } }

        its(:sha)          { should eq 'sha'     }
        its(:author)       { should eq 'author'  }
        its(:author_email) { should eq 'email'   }
        its(:message)      { should eq 'message' }
      end

      context "when fields does not exists in message" do
        let(:message_attributes) { {
          commit_sha:           '',
          commit_author:        '',
          commit_author_email:  '',
          commit_message:       ''
        } }

        its(:sha)          { should eq 'HEAD' }
        its(:author)       { should be_nil }
        its(:author_email) { should be_nil }
        its(:message)      { should be_nil }
      end

    end

  end

end
