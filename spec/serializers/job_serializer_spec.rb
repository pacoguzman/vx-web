require 'spec_helper'

describe JobSerializer do
  let(:object) { create :job }
  let(:serializer) { described_class.new object }

  context "as_json" do
    subject { serializer.as_json.keys }

    it { should eq [:id, :build_id, :project_id, :number, :status, :matrix,
                    :started_at, :finished_at] }
  end
end
