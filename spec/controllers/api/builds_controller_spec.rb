require 'spec_helper'

describe Api::BuildsController do
  let(:user)    { create :user }
  let(:project) { create :project }
  let(:build)   { create :build, project: project }

  subject { response }

  before do
    session[:user_id] = user.id
  end

  context "GET /index" do
    before { get :index, project_id: project.id, format: :json }

    it { should be_success }
    its(:body) { should_not be_blank }
  end

  context "GET /show" do
    before { get :show, id: build.id, format: :json }

    it { should be_success }
    its(:body) { should_not be_blank }
  end

  context "POST /create" do
    before { post :create, project_id: project.id, format: :json }

    it { should be_success }

    it "should delivery message to FetchBuildConsumer" do
      expect(FetchBuildConsumer.messages).to have(1).item
    end
  end
end
