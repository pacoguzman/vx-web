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
