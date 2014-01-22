require 'spec_helper'

describe RepoCallbacksController do

  subject { response }

  describe "GET /create" do
    let(:project) { create :project }
    let(:service) { 'github' }
    let(:params)  { {} }

    before do
      get :create, params.merge(token: project.token, _service: service)
    end

    it { should be_success }

    it "should delivery build to PayloadConsumer" do
      expect(PayloadConsumer.messages.last).to be
    end

  end
end
