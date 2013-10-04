require 'spec_helper'

describe Api::UsersController do
  let(:identity) { create :user_identity }
  let(:user) { identity.user }
  subject { response }

  before do
    session[:user_id] = user.id
  end

  context "GET /me" do
    before do
      get :me, format: "json"
    end

    it { should be_success }
  end
end
