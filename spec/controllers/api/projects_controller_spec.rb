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

end
