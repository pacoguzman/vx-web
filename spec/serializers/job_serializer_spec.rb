require 'spec_helper'

describe JobSerializer do
  let(:object) { create :job }
  let(:serializer) { described_class.new object }

  it "should successfuly serialize job" do
    expect(serializer.to_json).to be
  end

  context "#text_logs_url" do
    subject { serializer.text_logs_url }
    it { should eq "/api/jobs/#{object.id}/logs.txt" }
  end

  context "#natural_number" do
    subject { serializer.natural_number }

    before do
      object.build.number = 1
      object.number = 12345
    end
    it { should eq "1.0000012345" }
    it { should have(12).items }
  end
end
