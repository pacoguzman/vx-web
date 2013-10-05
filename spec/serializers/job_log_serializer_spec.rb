require 'spec_helper'

describe JobLogSerializer do
  let(:object) { create :job_log }
  let(:serializer) { described_class.new object }

  context "as_json" do
    subject { serializer.as_json.keys }

    it { should eq [:id, :job_id, :tm, :data] }
  end
end
