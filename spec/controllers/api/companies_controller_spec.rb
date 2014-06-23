require 'spec_helper'

describe Api::CompaniesController do
  let(:user) { create :user }

  subject { response }

  context "POST /default" do
    let(:c1) { create :company, name: 'c1', id: uuid_for(1) }
    let(:c2) { create :company, name: 'c2', id: uuid_for(2) }

    before do
      expect(user.add_to_company c1).to be
      expect(user.add_to_company c2).to be
      expect(user.default_company).to eq c2
      session[:user_id] = user.id
    end

    before { post :default, id: c1.id }
    it { should be_success }
    it "should set user default company" do
      expect(user.default_company).to eq c1
    end
  end

  describe 'GET usage' do
    it 'returns current company usage' do
      company = create(:company)
      user.add_to_company(company, 'admin')
      sign_in(user)

      get :usage

      expected_response = {
        today:        { job_count: 0, minutes: 0, amount: 0 },
        yesterday:    { job_count: 0, minutes: 0, amount: 0 },
        last_7_days:  { job_count: 0, minutes: 0, amount: 0 },
        this_month:   { job_count: 0, minutes: 0, amount: 0 }
      }
      expect(json_response).to eq(expected_response)
    end

    it 'returns status 403 if user is not an admin' do
      company = create(:company)
      user.add_to_company(company, 'developer')
      sign_in(user)

      get :usage

      expect(response).to be_forbidden
    end

    it 'returns status 403 if user is not signed in' do
      company = create(:company)
      user.add_to_company(company, 'admin')

      get :usage

      expect(response).to be_forbidden
    end
  end
end
