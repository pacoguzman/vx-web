require 'spec_helper'

describe Api::CompaniesController do
  let(:user) { create :user }

  subject { response }

  before do
    session[:user_id] = user.id
  end

  context "POST /default" do
    let(:c1) { create :company, name: 'c1', id: uuid_for(1) }
    let(:c2) { create :company, name: 'c2', id: uuid_for(2) }

    before do
      expect(user.add_to_company c1).to be
      expect(user.add_to_company c2).to be
      expect(user.default_company).to eq c2
    end

    before { post :default, id: c1.id }
    it { should be_success }
    it "should set user default company" do
      expect(user.default_company).to eq c1
    end

  end

end
