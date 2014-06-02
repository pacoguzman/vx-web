require 'spec_helper'

describe Api::ProjectsController do
  let(:project) { create :project }
  let(:user)    { project.user_repo.user }

  subject { response }

  before do
    project
    session[:user_id] = user.id
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
      get :key, id: project.id
    end
    it { should be_success }
    its(:content_type) { should eq 'text/plain' }

    it "has a body of the correct size" do
      subject.body.size.should eq 234
    end
  end

end
