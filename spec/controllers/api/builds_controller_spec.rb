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
    before do
      b
      get :index, project_id: project.id, format: :json
    end

    it { should be_success }
    its(:body) { should_not be_blank }
  end

  context "GET /show" do
    before { get :show, id: b.id, format: :json }

    it { should be_success }
    its(:body) { should_not be_blank }
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

    it "should be not found if sha invalid" do
      request.env['HTTP_X_VEXOR_PROJECT_TOKEN'] = project.token
      get :status_for_gitlab, id: 'invalid'
      should be_not_found
      expect(response.body).to eq '{}'
    end
  end

end
