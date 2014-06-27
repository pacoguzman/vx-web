require 'spec_helper'

describe UserSerializer do
  let(:user)       { create :user }
  let(:serializer) { described_class.new user }
  let(:company)    { create :company }

  it "should sucessfuly serialize" do
    expect(serializer.to_json).to_not be_empty
  end

end
