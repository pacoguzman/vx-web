require 'spec_helper'

describe Api::UsersController do
  let(:user)    { create(:user) }
  let(:company) { create(:company) }
  subject { response }

  context 'GET /me' do
    context "successfuly" do
      before do
        sign_in user
        get :me
      end
      it { should be_success }
    end
    context "failed" do
      it "when user is not logged in" do
        get :me
        should be_forbidden
      end
    end
  end

  context 'GET index' do
    before { sign_in user }

    context "successfuly" do
      before do
        user.add_to_company company, 'admin'
        get :index
      end
      it { should be_success }
    end

    context "failed" do
      it "when user is not admin" do
        user.add_to_company company
        get :index
        should be_forbidden
      end
    end
  end

  context "PATCH /update" do
    before { sign_in user }
    context "successfuly" do
      before do
        user.add_to_company company, 'admin'
        patch :update, id: user.id, user: { role: "admin" }
      end
      it { should be_success }
      it "should update user role" do
        expect(user).to be_admin(company)
      end
    end

    context "failed" do
      it "when role invalid" do
        user.add_to_company company, 'admin'
        patch :update, id: user.id, user: { role: "invalid" }
        expect(response.status).to eq 422
      end

      it "when user is not admin in current company" do
        user.add_to_company company
        patch :update, id: user.id, user: { role: "admin" }
        should be_forbidden
      end
    end
  end

end
