require 'spec_helper'

describe Users::InvitesController do
  subject { response }

  context "GET /new" do
    let(:company) { create :company }
    let(:invite)  { create :invite, company: company }

    context "successfuly" do
      before do
        get :new, email: invite.email, company: company.name, token: invite.token
      end
      it { should be_success }
      it { should render_template("new") }
    end

    context "when company is not found" do
      before do
        get :new, email: invite.email, company: 'not found', token: invite.token
      end
      it { should be_not_found }
    end

    context "when email is not found" do
      before do
        get :new, email: 'not found', company: company.name, token: invite.token
      end
      it { should be_not_found }
    end

    context "when token is not found" do
      before do
        get :new, email: invite.email, company: company.name, token: 'not found'
      end
      it { should be_not_found }
    end

  end
end
