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

