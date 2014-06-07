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
end

# == Schema Information
#
# Table name: invites
#
#  id         :integer          not null, primary key
#  company_id :integer          not null
#  token      :string(255)      not null
#  email      :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

