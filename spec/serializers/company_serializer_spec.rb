require 'spec_helper'

describe CompanySerializer do
  let(:object) { create :company }
  let(:serializer) { described_class.new object }

  context "as_json" do
    subject { serializer.as_json.keys }

    it { should eq [:id, :name] }
  end
end
