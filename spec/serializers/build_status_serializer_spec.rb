require 'spec_helper'

describe BuildStatusSerializer do
  let(:build) { create :build }
  let(:serializer) { described_class.new build }

  context "as_json" do
    subject { serializer.as_json.keys }

    it { should eq [:id, :project_id, :number, :status, :started_at, :finished_at] }
  end
end
