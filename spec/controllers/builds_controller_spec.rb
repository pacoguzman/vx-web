require 'spec_helper'

describe BuildsController do
  let(:project) { create :project }
  let(:user)    { project.user_repo.user }
  let(:build)   { create :build, project: project }

  subject { response }

  before do
    session[:user_id] = user.id
  end

  context "GET /sha/:sha (commit SHA1)" do
    before { get :sha, sha: build.sha, format: :json }

    it { should redirect_to("/builds/#{build.id}") }
  end

end
