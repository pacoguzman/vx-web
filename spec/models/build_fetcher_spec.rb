require 'spec_helper'

describe BuildFetcher do
  let(:project) { create :project }
  let(:payload) { Vx::ServiceConnector::Model.test_payload }
  let(:params)  { payload.to_hash.stringify_keys.merge("project_id" => project.id) }
  let(:fetcher) { described_class.new params }

  subject { fetcher }

  context "just created" do
    its(:project_id) { should eq project.id }
    its(:project)    { should eq project }
    its(:payload)    { should be }
    its(:source)     { should be }
    its(:matrix)     { should be }
  end

  context "#build" do
    subject { fetcher.build }

    it "should create build using payload" do
      expect(subject).to be_new_record

      expect(subject.sha).to eq 'HEAD'
      expect(subject.branch).to eq 'master'
    end
  end

  context "#perform" do
    let(:user)     { create :user }
    let(:identity) { create :user_identity, :github, user: user }
    let(:commit)   { Vx::ServiceConnector::Model.test_commit }
    let(:file)     { { "rvm" => "2.0.0" }.to_yaml }

    subject { fetcher.perform }

    before do
      fetcher.project.update! identity: identity if fetcher.project
    end

    context "success" do
      before do
        any_instance_of(Vx::ServiceConnector::Github) do |g|
          mock(g).commits(anything).mock!.get(payload.head) { commit }
          mock(g).files(anything).mock!.get(payload.head, '.travis.yml') { file }
        end
      end

      it { should be }

      it "should craate project build" do
        expect {
          subject
        }.to change(project.builds, :count).by(1)
        expect(subject).to_not be_new_record
      end

      it "should assign commit to build" do
        expect(subject.author).to eq 'author'
      end

      it "should assign source to build" do
        expect(subject.source.keys).to be_include("rvm")
      end

      it "should create jobs" do
        expect {
          subject
        }.to change(fetcher.build.jobs, :count).by(1)
        job = subject.jobs.first
        expect(job).to be
        expect(job.number).to eq 1
        expect(job.matrix).to eq({"rvm"=>"2.0.0"})
        expect(job.source).to be
      end

      it "should publish message to JobConsumer" do
        expect {
          subject
        }.to change(JobsConsumer.messages, :count).by(1)
      end
    end

    context "failed" do
      context "when fail to find project" do
        let(:params) { {} }

        it { should be_nil }
      end

      context "when ignore payload" do
        before do
          mock(fetcher.payload).ignore? { true }
        end
        it { should be_nil }
      end

      context "when fail to fetch source" do
        before do
          any_instance_of(Vx::ServiceConnector::Github) do |g|
            mock(g).files(anything).mock!.get(payload.head, '.travis.yml') { nil }
          end
        end

        it "cannot create any builds" do
          expect {
            subject
          }.to_not change(project.builds, :count)
        end
      end

      context "when fail to fetch commit" do
        before do
          any_instance_of(Vx::ServiceConnector::Github) do |g|
            mock(g).files(anything).mock!.get(payload.head, '.travis.yml') { file }
            mock(g).commits(anything).mock!.get(payload.head) { nil }
          end
        end

        it "cannot create any builds" do
          expect {
            subject
          }.to_not change(project.builds, :count)
        end
      end

      context "when jobs is empty" do
        before do
          any_instance_of(Vx::ServiceConnector::Github) do |g|
            mock(g).commits(anything).mock!.get(payload.head) { commit }
            mock(g).files(anything).mock!.get(payload.head, '.travis.yml') { "---\n" }
          end
        end

        it "cannot create any builds" do
          expect {
            subject
          }.to_not change(project.builds, :count)
        end
      end
    end

  end

end
