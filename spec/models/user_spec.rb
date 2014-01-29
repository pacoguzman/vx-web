require 'spec_helper'

describe User do
  let(:user) { User.new }
  subject { user }

  context "sync_repos" do
    let(:external_repo) { Vx::ServiceConnector::Model.test_repo }
    let(:user_repo)     { create :user_repo, external_id: external_repo.id }
    let(:identity)      { user_repo.identity }
    let(:user)          { identity.user }

    subject { user.sync_repos }

    before do
      any_instance_of(Vx::ServiceConnector::Github) do |g|
        mock(g).repos { [external_repo] }
      end
    end

    it { should be }

    it "should create missing user_repos" do
      user_repo.destroy
      expect {
        subject
      }.to change(identity.user_repos, :count).by(1)
    end

    it "should remove unupdated user_repos" do
      user_repo.update! external_id: -1
      expect(subject).to be
      expect{user_repo.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should update existing user_repos" do
      user_repo.update! description: "..."
      expect(subject).to be
      expect(user_repo.reload.description).to eq 'description'
    end

  end
end

# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string(255)      not null
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

