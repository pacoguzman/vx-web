require 'spec_helper'

describe UserSerializer do
  let(:object) { create :user }
  let(:serializer) { described_class.new object }

  context "as_json" do
    subject { serializer.as_json.keys }

    it { should eq [:id, :email, :name, :identities] }
  end
end
