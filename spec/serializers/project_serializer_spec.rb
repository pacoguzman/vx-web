require 'spec_helper'

describe ProjectSerializer do
  let(:object) { create :project }
  let(:serializer) { described_class.new object }

  context "as_json" do
    subject { serializer.as_json.keys }

    it { should eq [:id, :name, :http_url, :description, :status, :subscribed] }
  end
end
