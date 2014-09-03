require 'spec_helper'

describe ProjectSerializer do
  let(:object) { create :project }
  let(:serializer) { described_class.new object }

  context "as_json" do
    subject { serializer.as_json.keys }

    it { should be }
  end

  it "should find last_builds in object" do
    b = create :build, project: object

    s = described_class.new object
    mock(object).last_builds { [b] }
    expect(s.as_json[:last_builds].map{|i| i[:id] }).to eq [b.id]
  end

  it "should use last_builds from scope" do
    b = create :build, project: object

    scope = OpenStruct.new(
      last_builds: {
        object.id => [b]
      }
    )
    s = described_class.new object, scope: scope
    dont_allow(object).last_builds
    expect(s.as_json[:last_builds].map{|i| i[:id] }).to eq [b.id]
  end

  it "should successfuly serialize if id in scope.last_builds not found" do
    scope = OpenStruct.new(last_builds: {})
    s = described_class.new object, scope: scope
    dont_allow(object).last_builds
    expect(s.as_json[:last_builds].map{|i| i[:id] }).to eq []
  end

  def json(s)
    JSON.parse(s)
  end
end
