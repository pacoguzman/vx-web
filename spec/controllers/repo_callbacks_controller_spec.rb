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

      pending 'ask for perform the received payload' do
        expect_any_instance_of(Vx::ServiceConnector::Model::Payload).to receive(:payload?).and_call_original

        get :create, params.merge(_token: project.token, _service: service)
      end
    end

  end
end
