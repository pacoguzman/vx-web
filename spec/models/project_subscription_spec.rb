require 'spec_helper'

describe ProjectSubscription do
  let(:sub) { build :project_subscription }
  subject { sub }

  it { should be_valid }

  context ".subscribe_by_email" do
    let(:project) { create :project }
    let(:user)    { project.user_repo.user }
    let(:email)   { user.email }

    subject { described_class.subscribe_by_email email, project }

    context "when subscription is not exists" do
      it { should be_a(ProjectSubscription) }

      it "should subscribe user to project" do
        expect {
          subject
        }.to change(project.subscriptions, :count).by(1)
        expect(project.subscriptions.first.user).to eq user
        expect(project.subscriptions.first.subscribe).to be(true)
      end
    end

    context "when user not found" do
      let(:email) { 'not exists' }

      it { should be_nil }

      it "cannot touch any subscriptions" do
        expect {
          subject
        }.to_not change(project.subscriptions, :count)
      end
    end

    context "when user anready subscribed" do

      before do
        create :project_subscription, user: user, project: project, subscribe: false
      end

      it { should be_nil }

      it "cannot touch any subscriptions" do
        expect {
          subject
        }.to_not change(project.subscriptions, :count)
      end
    end
  end
end

# == Schema Information
#
# Table name: project_subscriptions
#
#  subscribe  :boolean          default(TRUE), not null
#  created_at :datetime
#  updated_at :datetime
#  user_id    :uuid             not null
#  project_id :uuid             not null
#  id         :uuid             not null, primary key
#

