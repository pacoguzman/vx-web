require 'spec_helper'

describe Company do
  let(:company) { build :company }
  subject { company }

  it { should be_valid }

  context "default_user_role" do
    let(:company) { create :company }
    let(:user)    { create :user }

    it "should be developer if any users exists" do
      user.add_to_company company
      expect(company.default_user_role).to eq 'developer'
    end

    it "should be admin if no any users" do
      expect(company.default_user_role).to eq 'admin'
    end
  end
end

# == Schema Information
#
# Table name: companies
#
#  name               :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  id                 :uuid             not null, primary key
#  billing_started_at :datetime
#

