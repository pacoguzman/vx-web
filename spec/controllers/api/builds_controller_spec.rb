require 'spec_helper'

describe Api::BuildsController do
  let(:project) { create :project }
  let(:user)    { project.user_repo.user }
  let(:build)   { create :build, project: project }

  subject { response }

  before do
    sign_in user, project.company
  end

  context "GET /index" do
    before do
      build
      get :index, project_id: project.id, format: :json
    end

    it { should be_success }
    its(:body) { should_not be_blank }
  end

  context "GET /show" do
    before { get :show, id: build.id, format: :json }

    it { should be_success }
    its(:body) { should_not be_blank }
  end

  context "GET /queued" do
    before do
      create(:build, project: project, number: nil, branch: "MyInitialized") # pending build or initialized by default
      create(:build_errored, project: project, number: nil)

      get :queued, format: :json
    end

    it { should be_success }
    its(:body) { should_not be_blank }

    it "returns the pending build" do
      subject.body.should include("branch\":\"MyInitialized")
    end

    it "returns only one build" do
      ActiveSupport::JSON.decode(subject.body).size.should == 1 # one build
    end
  end

  context "GET /sha/show (commit SHA1)" do
    before { get :sha, sha: build.sha, format: :json }

    it { should be_success }
    its(:body) { should_not be_blank }
  end

  context "POST /restart" do
    before do
      any_instance_of(Build) do |b|
        mock(b).restart { ret }
      end
      post :restart, id: build.id, format: :json
    end

    context "when success" do
      let(:ret) { build }

      it { should be_success }
      its(:body) { should_not be_blank }
    end

    context "when fail" do
      let(:ret) { nil }

      its(:response_code) { should eq 422 }
      its(:body) { should be_blank }
    end
  end

end
