require 'spec_helper'

describe Github::RepoCallbacksController do

  subject { response }

  describe "GET /create" do
    let(:project) { create :project }
    let(:params)  { read_json_fixture("github/push.json") }

    before do
      get :create, params.merge(token: project.token)
    end

    it { should be_success }

    it "should create build" do
      expect(project.builds.last).to be
    end

    it "should delivery build to FetchBuildConsumer" do
      expect(FetchBuildConsumer.messages.last).to eq Build.last.id
    end

  end

end
