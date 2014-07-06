require 'spec_helper'

describe Api::BuildsController do
  let(:project) { create :project }
  let(:user)    { project.user_repo.user }
  let(:b)       { create :build, project: project }

  subject { response }

  before do
    sign_in user, project.company
  end

  context "GET /index" do
    it "should return builds list" do
      create :build, project: project
      get :index, project_id: project.id, format: :json
      should be_success
      expect(response.body).to_not be_blank
    end

    it "should return builds in specifed branch" do
      create :build, project: project, branch_label: "foo"
      get :index, project_id: project.id, format: :json, branch: "foo"
      should be_success
      expect(response.body).to_not be_blank
    end
  end

  context "GET /show" do
    before { get :show, id: b.id, format: :json }

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

  context "POST /restart" do
    before do
      any_instance_of(Build) do |b|
        mock(b).restart { ret }
      end
      post :restart, id: b.id, format: :json
    end

    context "when success" do
      let(:ret) { b }

      it { should be_success }
      its(:body) { should_not be_blank }
    end

    context "when fail" do
      let(:ret) { nil }

      its(:response_code) { should eq 422 }
      its(:body) { should be_blank }
    end
  end

  context "GET /status_for_gitlab" do

    it "should be success if project and build found" do
      request.env['HTTP_X_VEXOR_PROJECT_TOKEN'] = project.token
      get :status_for_gitlab, id: b.sha
      should be_success
      expect(response.body).to eq({
        status: :pending,
        location: b.public_url
      }.to_json)
    end

    it "should be not found if token missing" do
      get :status_for_gitlab, id: b.sha
      should be_not_found
      expect(response.body).to eq '{}'
    end

    it "should be not found if token invalid" do
      request.env['HTTP_X_VEXOR_PROJECT_TOKEN'] = 'invalid'
      get :status_for_gitlab, id: b.sha
      should be_not_found
      expect(response.body).to eq '{}'
    end

    it "should be not found if build with sha not found" do
      request.env['HTTP_X_VEXOR_PROJECT_TOKEN'] = project.token
      get :status_for_gitlab, id: '3205261774800570a7f9b5f8687672c21847caaf'
      should be_not_found
      expect(response.body).to eq '{}'
    end
  end

end
