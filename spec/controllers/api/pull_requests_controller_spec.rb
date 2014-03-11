require 'spec_helper'

describe Api::PullRequestsController do
  let(:project)       { create :project }
  let(:user)          { project.user_repo.user }
  let(:build)         { create :build, project: project }
  let(:build_with_pr) { create :build, project: project, pull_request_id: 10, number: nil }

  subject { response }

  before do
    session[:user_id] = user.id
  end

  context "GET /index" do
    before do
      build
      build_with_pr

      get :index, project_id: project.id, format: :json
    end

    it { should be_success }
    it "returns the build with pull request" do
      subject.body.should include("pull_request_id\":10")
    end
    it "returns only build with pull request" do
      ActiveSupport::JSON.decode(subject.body).size.should == 1 # one build
    end
  end
end
