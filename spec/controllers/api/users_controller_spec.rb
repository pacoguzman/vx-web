require 'spec_helper'

describe Api::UsersController do
  let(:user)    { create(:user) }
  let(:company) { create(:company) }
  subject { response }

  context 'GET /me' do
    context "successfuly" do
      before do
        sign_in user, company
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
        user.add_to_company company, role: :admin
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
        user.add_to_company company, role: :admin
        patch :update, id: user.id, user: { role: "developer" }
      end
      it { should be_success }
      it "should update user role" do
        expect(user).to be_developer(company)
      end
    end

    context "failed" do
      it "when role invalid" do
        user.add_to_company company, role: :admin
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

  describe 'DELETE destroy' do
    context 'successfully' do
      it 'returns status 200' do
        another_user = create(:user, email: 'another.user@example.com', id: uuid_for(1))
        another_user.add_to_company(company, role: :admin)
        user.add_to_company(company, role: :admin)
        sign_in(user)

        delete :destroy, id: another_user

        expect(response).to be_success
      end

      it 'deletes user from company' do
        another_user = create(:user, email: 'another.user@example.com', id: uuid_for(1))
        another_user.add_to_company(company, role: :admin)
        user.add_to_company(company, role: :admin)
        sign_in(user)

        delete :destroy, id: another_user

        expect(another_user.companies).to be_empty
      end
    end

    context 'when failed' do
      it 'returns status 403 if user is not an admin' do
        user.add_to_company(company, role: :developer)
        sign_in(user)

        delete :destroy, id: user

        expect(response).to be_forbidden
      end

      it 'returns status 405 if it is current user' do
        user.add_to_company(company, role: :admin)
        sign_in(user)

        delete :destroy, id: user

        expect(response).to be_method_not_allowed
      end

      it 'does not allow to delete current user from current company' do
        user.add_to_company(company, role: :admin)
        sign_in(user)

        delete :destroy, id: user

        expect(user.companies).not_to be_empty
      end
    end
  end
end
