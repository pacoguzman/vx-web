require 'spec_helper'

describe Api::UserIdentities::GitlabController do
  let(:identity) { create :user_identity, :gitlab }
  let(:user)     { identity.user }
  let(:company)  { create :company }
  let(:gitlab)   { 'session' }
  let(:attrs)   { {
    "login"    => "login",
    "password" => "password",
    "url"      => 'url'
  } }
  subject { response }

  before do
    sign_in user, company
  end

  context "PATCH /update" do
    before do
      mock(UserSession::Gitlab).new(attrs) { gitlab }
    end

    context "successfuly update identity" do
      before do
        mock(gitlab).update_identity(anything) { true }
        patch :update, { id: identity.id, user_identity: attrs }
      end
      it { should be_success }
      its(:body) { should be_empty }
    end

    context "fail to update identity" do
      before do
        mock(gitlab).update_identity(anything) { false }
        patch :update, { id: identity.id, user_identity: attrs }
      end
      its(:code) { should eq "422" }
    end
  end

  context "POST /create" do
    before do
      mock(UserSession::Gitlab).new(attrs) { gitlab }
    end

    context "successfuly create identity" do
      before do
        mock(gitlab).create_identity(anything) { identity }
        post :create, { user_identity: attrs }
      end
      it { should be_success }
      its(:body) { should_not be_empty }
    end

    context "fail to create identity" do
      before do
        mock(gitlab).create_identity(anything) { false }
        post :create, { user_identity: attrs }
      end
      its(:code) { should eq "422" }
    end
  end

  context "DELETE /destroy" do
    context "successfuly unsubscribe and destroy identity" do
      before do
        delete :destroy, id: identity.id
      end
      it { should be_success }
    end
  end
end
