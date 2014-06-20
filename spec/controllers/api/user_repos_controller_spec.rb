require 'spec_helper'

describe Api::UserReposController do
  let(:company) { repo.company }
  let(:repo)    { create :user_repo }
  let(:user)    { repo.user }
  subject { response }

  before do
    sign_in user, company
  end

  context "GET /index" do
    before do
      repo
      get :index, format: :json
    end
    it { should be_success }
    its(:body) { should_not be_empty }
  end

  context "POST /sync" do
    before do
      repo
      mock(User).find_by(id: user.id) { user }
      mock(user).sync_repos(company) { true }
      post :sync, format: :json
    end
    it { should be_success }
    its(:body) { should_not be_empty }
  end

  context "POST /subscribe" do
    before do
      any_instance_of(UserRepo) do |r|
        mock(r).subscribe { true }
      end
      post :subscribe, id: repo.id, format: :json
    end

    it { should be_success }
    its(:body) { should_not be_empty }
  end

  context "POST /unsubscribe" do
    before do
      any_instance_of(UserRepo) do |r|
        mock(r).unsubscribe { true }
      end
      post :unsubscribe, id: repo.id, format: :json
    end
    it { should be_success }
    its(:body) { should_not be_empty }
  end
end
