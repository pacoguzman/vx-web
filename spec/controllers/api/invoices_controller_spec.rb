require 'spec_helper'

describe Api::InvoicesController do
  let(:invoice) { create :invoice }
  let(:user) { create :user }
  subject { response }

  before do
    sign_in user, invoice.company
  end

  context "GET /index" do
    it "should be success" do
      get :index
      should be_success
    end
  end

end
