require 'spec_helper'

describe LastBuildSerializer do
  let(:object) { create :build }
  let(:serializer) { described_class.new object }

  it "should successfuly serialize" do
    expect(serializer.to_json).to be
  end
end
