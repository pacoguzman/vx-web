require 'spec_helper'

describe UserListSerializer do
  let(:user)       { create :user }
  let(:company)    { create :company }
  let(:serializer) { described_class.new user, scope: company }

  before do
    user.add_to_company company
  end

  it "should sucessfuly serialize" do
    puts company.inspect
    expect(serializer.to_json).to_not be_empty
  end

  it "should have role key" do
    expect(serializer.as_json[:role]).to eq 'developer'
  end

end
