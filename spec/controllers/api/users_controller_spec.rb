require 'spec_helper'

describe Api::UsersController do
  let!(:admin) { create(:user, email: 'admin@example.com') }
  let!(:user) { create(:user, email: 'user@example.com') }
  let!(:company) { create(:company) }
  let!(:admin_company) { create(:user_company, company: company, user: admin, role: UserCompany::ADMIN_ROLE) }
  let!(:user_company) { create(:user_company, company: company, user: user, role: UserCompany::DEVELOPER_ROLE) }

  context 'GET /me' do
    it 'returns status 200' do
      sign_in(user)
      get :me

      expect(response).to be_success
    end
  end

  describe 'GET index' do
    it 'returns company\'s users' do
      sign_in(admin)
      get :index

      ids = json_response.map { |u| u['id'] }
      expect(ids).to match_array([admin.id, user.id])
    end

    it 'returns status 403 if not admin' do
      sign_in(user)
      get :index

      expect(response).to be_forbidden
    end
  end

  describe 'PATCH update' do
    it 'returns company\'s users' do
      sign_in(admin)
      patch :update, id: user.id, user: { role: UserCompany::ADMIN_ROLE }

      expect(json_response['id']).to eq(user.id)
      expect(json_response['role']).to eq(UserCompany::ADMIN_ROLE)
    end

    it 'returns status 422 if not valid params' do
      sign_in(admin)
      patch :update, id: user.id, user: { role: 'not valid role' }

      expect(response.status).to eq(422)
    end

    it 'returns status 403 if not admin' do
      sign_in(user)
      patch :update, id: user.id, user: {}

      expect(response).to be_forbidden
    end
  end
end
