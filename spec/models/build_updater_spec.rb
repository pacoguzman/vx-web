require 'spec_helper'

describe BuildUpdater do
  let(:build_id) { 1 }
  let(:project)  { create :project }
  let(:message_attributes) { {} }
  let(:message)  {
    Evrone::CI::Message::BuildStatus.test_message(
      message_attributes.merge build_id: build_id
    )
  }
  let(:updater)  { BuildUpdater.new message }
  subject { updater }

  context "just created" do
    its(:message){ should eq message }
  end

  context "perform" do
    subject { updater.perform }

    context "when build does not exists" do
      it { should be_nil }
      it "cannot touch any builds" do
        expect{ subject }.to_not change(Build, :count)
      end
    end

    context "when build exists" do
      let!(:b) { create :build, project: project, id: build_id }

      it { should eq b }

      it "should publish build" do
        any_instance_of(Build) do |b|
          mock(b).publish
        end
        subject
      end

      it "should publish build.project" do
        any_instance_of(Project) do |b|
          mock(b).publish
        end
        subject
      end

      context "update build status" do
        let(:tm) { Time.now }
        let(:message_attributes) { {
          status: status,
          tm:     tm.to_i,
        } }

        subject { updater.perform }

        context "when status 2 (STARTED)" do
          let(:status) { 2 }

          its(:status_name) { should eq :initialized }
          its("started_at") { should be_nil  }
        end

        context "when status 3 (FINISHED)" do
          let(:status) { 3 }

          it "cannot touch build.status" do
            expect{ subject }.to_not change{ b.reload.status }
          end
        end

        context "when status 4 (FAILED)" do
          let(:status) { 4 }
          before { b.start }

          its(:status_name)       { should eq :failed }
          its("finished_at.to_i") { should eq tm.to_i }
        end

        context "when status 5 (ERRORED)" do
          let(:status) { 5 }
          before { b.start }

          its(:status_name)       { should eq :errored }
          its("finished_at.to_i") { should eq tm.to_i }
        end
      end

      context "add jobs count to build" do
        let(:message_attributes) { { jobs_count: 99 } }

        it "should be success" do
          expect{
            subject
          }.to change{ b.reload.jobs_count }.to(99)
        end
      end

    end


  end

end
