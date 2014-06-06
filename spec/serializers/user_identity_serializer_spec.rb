require 'spec_helper'

describe UserIdentitySerializer do
  let(:object) { create :user_identity }
  let(:serializer) { described_class.new object }

  context "as_json" do
    subject { serializer.as_json.keys }

    it { should eq [:id, :provider, :version, :login, :url] }
  end
end
