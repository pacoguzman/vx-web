require 'spec_helper'

describe Github::UserCallbacksController do

  subject { response }

  context "GET /create" do

    context "success" do
      let(:user) { OpenStruct.new id: 1 }

      before do
        mock(User).from_github(anything) { user }
        get :create
      end

      it { should redirect_to('/') }
    end

    context "fail" do

      before do
        mock(User).from_github(anything) { nil }
        get :create
      end

      it { should redirect_to('/auth/failure') }
    end

  end

end
