require 'spec_helper'
require 'ostruct'

shared_examples 'UserRepo#(un)subscribe cannot touch any projects' do
  it "should be return nil" do
    expect( subject ).to be_nil
  end

  it "cannot touch any projects" do
    expect{ subject }.to_not change(Project, :count)
  end
end

describe UserRepo do
  let(:repo) { create :user_repo }

  context "same_name_projects association" do
    let(:project) { create :project, name: repo.full_name, user_repo: nil }
    subject { repo.same_name_projects }
    it { should eq [project] }
  end

  context ".find_or_create_by_sc" do
    let(:identity) { repo.identity }
    let(:model)    { Vx::ServiceConnector::Model.test_repo }
    subject { described_class.find_or_create_by_sc identity, model }

    it { should be }

    context "when repo is not exists" do
      before { repo.update! external_id: -1 }

      it "should create a new user_repo" do
        identity
        expect{
          subject
        }.to change(described_class, :count).by(1)
      end
    end

    context "when already exists with same external_id" do
      it "should return existing repo" do
        repo.update! external_id: model.id
        expect {
          subject
        }.to_not change(described_class, :count)
        expect(subject).to eq repo
      end
    end

  end

  context "#unsubscribe" do
    let(:user)     { repo.user   }
    let!(:project) { create :project, user_repo: repo }
    subject { repo.unsubscribe }

    before do
      repo.update_attributes! :subscribed => true
    end

    context "when associated project does not exists" do
      before { project.destroy }

      it "should change 'subscribed' to false" do
        expect{ subject }.to change(repo, :subscribed).to(false)
      end
      it "should return true value" do
        expect(subject).to be_true
      end
    end

    context "when asscociated project exists" do
      before do
        any_instance_of(Vx::ServiceConnector::Github) do |g|
          mock(g).hooks(anything).mock!.destroy('test.local') { true }
          mock(g).deploy_keys(anything).mock!.destroy(project.deploy_key_name) { true }
        end
      end

      it "should change 'subscribed' to false" do
        expect{ subject }.to change(repo, :subscribed).to(false)
      end

      it "should destroy project" do
        expect { subject }.to change(repo.project, :persisted?).to(false)
      end

      it "should return true value" do
        expect(subject).to be_true
      end
    end
  end

  context "#subscribe" do
    let(:user) { repo.user }
    subject { repo.subscribe }

    context "when associated project exists" do
      let!(:project) { create :project, user_repo: repo }
      before do
        mock(repo).unsubscribe_project
        any_instance_of(Vx::ServiceConnector::Github) do |g|
          mock(g).hooks(anything).mock!.create(anything, anything)
          mock(g).deploy_keys(anything).mock!.create(
            project.deploy_key_name,
            project.public_deploy_key
          )
        end
      end

      it "cannot touch any projects" do
        expect{ subject }.to_not change(Project, :count)
      end

      it "should return true value" do
        expect(subject).to be_true
      end

      it "should change 'subscribed' to true" do
        expect{ subject }.to change(repo, :subscribed).to(true)
      end
    end

    context "when associated project does not exists" do
      before do
        mock(repo).unsubscribe_project
        any_instance_of(Vx::ServiceConnector::Github) do |g|
          mock(g).hooks(anything).mock!.create(anything, anything)
          mock(g).deploy_keys(anything).mock!.create(anything, anything)
        end
      end

      it "should create a new github project" do
        expect{ subject }.to change(repo, :project).from(nil)
        expect(repo.project.persisted?).to be_true
      end

      it "should change 'subscribed' to true" do
        expect{ subject }.to change(repo, :subscribed).to(true)
      end

      context "created github project" do
        subject { repo.project }
        before  { repo.subscribe }
        its(:name)        { should eq repo.full_name   }
        its(:http_url)    { should eq repo.html_url    }
        its(:clone_url)   { should eq repo.ssh_url     }
        its(:description) { should eq repo.description }
      end
    end

  end

  context "settings_url" do
    subject { user_repo.settings_url }

    context "for github" do
      let(:user_repo) { build :user_repo, :github }
      it { should eq 'https://github.com/settings/hooks' }
    end

    context "for gitlab" do
      let(:user_repo) { build :user_repo, :gitlab }
      it { should eq 'https://gitlab.example.com/hooks' }
    end
  end

  context "provider_title" do
    subject { user_repo.provider_title }

    context "for github" do
      let(:user_repo) { build :user_repo, :github }
      it { should eq 'Github' }
    end

    context "for gitlab" do
      let(:user_repo) { build :user_repo, :gitlab }
      it { should eq 'Gitlab' }
    end
  end

end

# == Schema Information
#
# Table name: user_repos
#
#  id                 :integer          not null, primary key
#  organization_login :string(255)
#  full_name          :string(255)      not null
#  is_private         :boolean          not null
#  ssh_url            :string(255)      not null
#  html_url           :string(255)      not null
#  subscribed         :boolean          default(FALSE), not null
#  description        :text
#  created_at         :datetime
#  updated_at         :datetime
#  identity_id        :integer          not null
#

