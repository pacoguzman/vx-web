require 'spec_helper'

describe Users::InvitesController do
  subject { response }

  context "GET /new" do
    let(:company) { create :company }
    let(:invite)  { create :invite, company: company }

    context "successfuly" do
      before do
        get :new, i: invite.id, t: invite.token
      end
      it { should be_success }
      it { should render_template("new") }
    end

    context "when token is not found" do
      before do
        get :new, i: invite.id, t: 'not found'
      end
      it { should be_not_found }
    end

    context "when invite.id is not found" do
      before do
        get :new, i: uuid_for(9), t: invite.token
      end
      it { should be_not_found }
    end

  end
end
