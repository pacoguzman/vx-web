require 'spec_helper'

describe BuildSerializer do
  let(:build) { create :build }
  let(:serializer) { described_class.new build }

  it "should successfuly serialize" do
    expect(serializer.to_json).to_not be_empty
  end
end
