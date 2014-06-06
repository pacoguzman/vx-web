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
