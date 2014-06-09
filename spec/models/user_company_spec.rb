require 'spec_helper'

describe UserCompany do
  let(:user_company) { build :user_company }
  subject { user_company }

  it { should be_valid }

  context "#default!" do
    let(:user_company)      { create :user_company, default: 0 }
    let(:user)              { user_company.user }
    let(:other_company)     { create :company, name: "other", id: 2 }
    let!(:other_user_company) { create :user_company, user: user, company: other_company, default: 1 }

    subject { user_company.default! }

    it "should make this company to default" do
      expect(user_company).to_not be_default
      expect(other_user_company).to be_default
      subject
      expect(user_company.reload).to be_default
      expect(other_user_company.reload).to_not be_default
    end
  end

  context 'role' do
    it 'has admin role if user is the first one in company' do
      user_company = create(:user_company)

      expect(user_company.role).to eq(UserCompany::ADMIN_ROLE)
    end

    it 'has developer role if company already has user' do
      company = create(:company)
      user1 = create(:user, email: 'user1@example.com')
      user_company1 = create(:user_company, company: company, user: user1)
      user2 = create(:user, email: 'user2@example.com')
      user_company2 = create(:user_company, company: company, user: user2)

      expect(user_company2.role).to eq(UserCompany::DEVELOPER_ROLE)
    end
  end
end

# == Schema Information
#
# Table name: user_companies
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  company_id :integer          not null
#  default    :integer          default(0), not null
#  created_at :datetime
#  updated_at :datetime
#

