require 'spec_helper'

describe CurrentUserSerializer do
  let(:user)       { create :user }
  let(:serializer) { described_class.new user }
  let(:company)    { create :company }

  before do
    user.add_to_company company
    create :user_identity, user_id: user.id
  end

  context "as_json" do
    subject { serializer.as_json.keys.sort }

    it { should be }
  end

  context "current_company" do
    subject { serializer.current_company }
    it { should eq company.id }
  end

  context "#project_subscriptions" do
    let(:project) { create :project, company: company }
    let(:sub)     { create :project_subscription, user: user, project: project }
    subject       { serializer.project_subscriptions }

    it { should eq [sub.project_id] }
  end
end
