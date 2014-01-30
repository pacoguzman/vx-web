require 'spec_helper'

describe RepoCallbacksController do

  subject { response }

  describe "GET /create" do
    let(:project) { create :project }
    let(:service) { 'github' }
    let(:params)  { {} }

    before do
      get :create, params.merge(_token: project.token, _service: service)
    end

    context "when github" do
      it { should be_success }

      it "should delivery build to PayloadConsumer" do
        expect(PayloadConsumer.messages.last).to be
      end
    end

  end
end
