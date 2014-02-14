require 'spec_helper'

describe PerformBuild do
  let(:project)       { create :project }
  let(:payload)       { Vx::ServiceConnector::Model.test_payload }
  let(:params)        { payload.to_hash.stringify_keys.merge("project_id" => project.id) }
  let(:perform_build) { described_class.new params }

  subject { perform_build }

  context "just created" do
    before { mock_file_request ({script: "true"}).to_yaml }

    its(:project_id) { should eq project.id }
    its(:project)    { should eq project }
    its(:payload)    { should be }
    its(:build)      { should be }
  end

  context "#process" do
    let(:user)     { project.user_repo.user }
    let(:commit)   { Vx::ServiceConnector::Model.test_commit }
    let(:file)     { { "rvm" => "2.0.0" }.to_yaml }

    subject { perform_build.process }
    before { mock_file_request file }

    context "success" do

      it { should be }

      it "should craate project build" do
        expect {
          subject
        }.to change(project.builds, :count).by(1)
        expect(subject).to_not be_new_record
      end

      it "should assign commit to build" do
        expect(subject.author).to eq 'User Name'
      end

      it "should assign source to build" do
        expect(subject.source.keys).to be_include("rvm")
      end

      it "should create jobs" do
        expect {
          subject
        }.to change(perform_build.build.jobs, :count).by(1)
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
          mock(perform_build.payload).ignore? { true }
        end
        it { should be_nil }
      end

      context "when fail to fetch source" do
        let(:file) { nil }

        it "cannot create any builds" do
          expect {
            subject
          }.to_not change(project.builds, :count)
        end
      end

      context "when jobs is empty" do
        let(:file) { "---\n" }
        it "cannot create any builds" do
          expect {
            subject
          }.to_not change(project.builds, :count)
        end
      end
    end
  end

  def mock_file_request content
    json = if content
             { "content" => Base64.encode64(content) }.to_json
           else
             nil
           end
    status = json ? 200 : 404
    stub_request(:get, "https://api.github.com/repos/ci-worker-test-repo/contents/.travis.yml?ref=HEAD").
      to_return(:status => status,
                :body => json,
                :headers => {"Content-Type" => "application/json"})
  end

end
