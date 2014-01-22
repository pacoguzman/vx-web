require 'spec_helper'
require 'ostruct'

shared_examples 'github repo common attributes' do
  its(:full_name)   { should eq 'full name'   }
  its(:is_private)  { should eq true          }
  its(:ssh_url)     { should eq 'ssh url'     }
  its(:html_url)    { should eq 'html url'    }
  its(:user)        { should eq user          }
  its(:description) { should eq 'description' }
end

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

end

# == Schema Information
#
# Table name: github_repos
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  organization_login :string(255)
#  full_name          :string(255)      not null
#  is_private         :boolean          not null
#  ssh_url            :string(255)      not null
#  html_url           :string(255)      not null
#  subscribed         :boolean          default(FALSE), not null
#  description        :text
#  created_at         :datetime
#  updated_at         :datetime
#

