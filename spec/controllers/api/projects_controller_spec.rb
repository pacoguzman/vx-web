require 'spec_helper'

describe Api::ProjectsController do
  let(:project) { create :project }
  let(:user)    { project.user_repo.user }

  subject { response }

  before do
    project
    sign_in user, project.company
  end

  context "GET /index" do
    before { get :index, format: :json }

    it { should be_success }
    its(:body) { should_not be_blank }
  end

  context "GET /show" do
    before { get :show, id: project.id, format: :json }

    it { should be_success }
    its(:body) { should_not be_blank }
  end

  context "GET /key" do
    before do
      session[:user_id] = nil
      get :key, id: project.id, format: "txt"
    end
    it { should be_success }
    its(:content_type) { should eq 'text/plain' }

    it "has a body of the correct size" do
      subject.body.size.should eq 233
    end
  end

  context "POST /rebuild" do

    before do
      create(:build, status: 3, project: project, branch: "foo")
    end

    def rebuild(token = nil)
      post :rebuild, id: (token || project.token), branch: 'foo'
    end

    it "should create new build" do
      expect {
        rebuild
      }.to change(project.builds, :count).by(1)
      should be_success
    end

    it "should return 201 status" do
      rebuild
      expect(response.status).to eq 201
    end

    it "should return json response" do
      rebuild
      expect(response.body).to_not be_empty
      expect(response.content_type).to eq 'application/json'
    end

    it "should return 404 if project id not found" do
      rebuild uuid_for(0)
      should be_not_found
    end

    it "should return 422 if build is not created" do
      project.builds.update_all status: 0
      rebuild
      expect(response.status).to eq 422
    end

  end

  context "GET /branches" do
    before do
      create :build, project: project, branch_label: "foo"
    end

    it "should return list of branches" do
      get :branches, id: project.id
      should be_success
      expect(response.body).to eq %w{foo}.to_json
    end

  end

end
