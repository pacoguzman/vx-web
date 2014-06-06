require 'spec_helper'

describe Api::InvitesController do
  describe 'POST create' do
    let!(:admin) { create(:user, email: 'admin@example.com') }
    let!(:user) { create(:user, email: 'user@example.com') }
    let!(:company) { create(:company) }
    let!(:admin_company) { create(:user_company, company: company, user: admin, role: UserCompany::ADMIN_ROLE) }
    let!(:user_company) { create(:user_company, company: company, user: user, role: UserCompany::DEVELOPER_ROLE) }

    it 'creates new invites' do
      emails = 'invite1@example.com invite2@example.com'
      sign_in(admin)

      post :create, invite: { emails: emails }

      expect(response).to be_success
      expect(Invite.pluck(:email)).to match_array(emails.split(' '))
    end

    it 'sends new invites' do
      ActionMailer::Base.deliveries.clear
      emails = 'invite1@example.com invite2@example.com'
      sign_in(admin)

      post :create, invite: { emails: emails }

      expect(ActionMailer::Base.deliveries.count).to eq(2)
    end

    it 'returns 403 status if admin not signed in' do
      sign_in(user)
      post :create, invite: { email: 'invite@example.com' }
      expect(response).to be_forbidden
    end
  end
end
