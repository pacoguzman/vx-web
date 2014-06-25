require 'spec_helper'

describe ProjectSerializer do
  let(:object) { create :project }
  let(:serializer) { described_class.new object }

  context "as_json" do
    subject { serializer.as_json.keys }

    it { should be }
  end

  it "should find last_build in object" do
    b = create :build, project: object

    s = described_class.new object
    mock(object).last_build { b }
    expect(s.as_json[:last_build][:id]).to eq b.id
  end

  it "should find last_build in scope" do
    b = create :build, project: object

    s = described_class.new object, scope: OpenStruct.new(last_builds: [b])
    dont_allow(object).last_build
    expect(s.as_json[:last_build][:id]).to eq b.id
  end

  def json(s)
    JSON.parse(s)
  end
end
