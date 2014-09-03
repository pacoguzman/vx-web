require 'spec_helper'

describe Api::InvitesController do
  subject { response }

  context "POST /create" do
    let(:company) { create :company }
    let(:user)    { create :user }

    before { sign_in user }

    context "successfuly" do
      before do
        user.add_to_company(company, role: :admin)
        post :create, invite: { emails: "user1@example.com user2@example.com" }
      end
      it { should be_success }

      it "should create invites" do
        expect(company.invites.size).to eq 2
      end

      it "should delivery emails" do
        expect(UserMailer.deliveries.size).to eq 2
      end
    end

    context "failed" do
      it "when user is not admin" do
        user.add_to_company(company)
        post :create, invite: { emails: "user1@example.com user2@example.com" }
        should be_forbidden
      end
    end
  end

end
