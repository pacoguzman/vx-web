require 'spec_helper'

describe User do
  let(:user) { User.new }
  subject { user }

  context "sync_repos" do
    let(:external_repo) { Vx::ServiceConnector::Model.test_repo }
    let(:user_repo)     { create :user_repo, full_name: external_repo.full_name }
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
      user_repo.update! full_name: "..."
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
