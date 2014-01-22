require 'spec_helper'

describe UserSerializer do
  let(:object) { create :user }
  let(:serializer) { described_class.new object }

  context "as_json" do
    subject { serializer.as_json.keys }

    it { should eq [:id, :email, :name, :project_subscriptions, :identities] }
  end

  context "#project_subscriptions" do
    let(:sub)    { create :project_subscription }
    let(:object) { sub.user }
    subject { serializer.project_subscriptions }

    it { should eq [sub.project_id] }
  end
end
