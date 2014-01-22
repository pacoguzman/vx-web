require 'spec_helper'

describe UserRepoSerializer do
  let(:object)     { create :user_repo }
  let(:serializer) { described_class.new object }

  context "as_json" do
    subject { serializer.as_json.keys }

    it { should eq [:id, :full_name, :html_url, :subscribed, :disabled] }
  end
end
