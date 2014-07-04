require 'spec_helper'

describe Invite do
  let(:invite) { build :invite }
  subject { invite }

  it { should be_valid }

  it "should generate token" do
    invite.token = nil
    invite.save!
    expect(invite.token).to_not be_empty
  end

  context ".mass_create" do
    let(:company) { create :company }
    subject {
      Invite.mass_create "user2@example.com user1@example.com", company
    }

    context "successfuly" do
      it "should be" do
        expect(subject.size).to eq 2
      end

      it "should create invites" do
        expect{ subject }.to change(company.invites, :count).by(2)
      end
    end

    context "failed" do
      before do
        mock(SecureRandom).uuid { nil }
      end

      it "should be nil" do
        expect(subject).to be_nil
      end

      it "cannot create any invites" do
        expect{ subject }.to_not change(company.invites, :count)
      end
    end
  end
end

# == Schema Information
#
# Table name: invites
#
#  token      :string(255)      not null
#  email      :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  company_id :uuid             not null
#  id         :uuid             not null, primary key
#  role       :string(255)      default("developer"), not null
#

