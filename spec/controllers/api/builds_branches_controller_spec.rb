require 'spec_helper'

describe Api::BuildsBranchesController do
  let(:project) { create :project }
  let(:user)    { project.user_repo.user }
  let(:build)   { create :build, project: project }
  let(:build2)  { create :build, project: project, number: nil }

  subject { response }

  before do
    sign_in user, project.company
  end

  context "GET /index" do
    before do
      build
      build2

      get :index, project_id: project.id, format: :json
    end

    it { should be_success }
    it "returns the last build of the branch" do
      subject.body.should include("branch\":\"MyString")
      subject.body.should include("id\":\"#{build2.id}\"")
    end
    it "returns only one build" do
      ActiveSupport::JSON.decode(subject.body).size.should == 1 # one build
    end
  end
end
