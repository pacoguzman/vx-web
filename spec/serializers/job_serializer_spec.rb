require 'spec_helper'

describe JobSerializer do
  let(:object) { create :job }
  let(:serializer) { described_class.new object }

  context "as_json" do
    subject { serializer.as_json.keys }

    it { should eq [:id, :build_id, :project_id, :number, :status, :matrix,
                    :started_at, :finished_at, :text_logs_url] }

  end

  context "#text_logs_url" do
    subject { serializer.text_logs_url }
    it { should eq "/api/jobs/#{job.id}/logs.txt" }
  end
end
