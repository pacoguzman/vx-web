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

shared_examples 'Github::Repo#(un)subscribe cannot touch any projects' do
  it "should be return nil" do
    expect( subject ).to be_nil
  end

  it "cannot touch any projects" do
    expect{ subject }.to_not change(Project, :count)
  end
end

describe Github::Repo do
  let(:repo) { create :github_repo }

  context "#project" do
    subject { repo.project }

    context "when associated github project exists" do
      let!(:project) { create :project, :github, name: repo.full_name }

      it { should eq project }
    end

    context "when associated project does not exists" do
      it { should be_nil }
    end
  end

  context "#unsubscribe" do
    let(:user)    { repo.user   }
    let(:project) { Project.new }
    subject { repo.unsubscribe }

    before do
      repo.update_attributes! :subscribed => true
    end

    context "successfuly" do

      context "when associated project does not exists" do
        it "should change 'subscribed' to false" do
          expect{ subject }.to change(repo, :subscribed).to(false)
        end
        it "should return true value" do
          expect(subject).to be_true
        end
      end

      context "when asscociated project exists" do
        before do
          stub(repo).project  { project }
          stub(repo).project? { true    }
          mock(project).save  { true    }
          mock(user).remove_hook_from_github_project(project)       { true }
          mock(user).remove_deploy_key_from_github_project(project) { true }
        end

        it "should change 'subscribed' to false" do
          expect{ subject }.to change(repo, :subscribed).to(false)
        end

        it "should return true value" do
          expect(subject).to be_true
        end
      end
    end

    context "fail" do
      before do
        stub(repo).project  { project }
        stub(repo).project? { true    }
      end

      context "when unable to update attribute 'subscribed'" do
        include_examples 'Github::Repo#(un)subscribe cannot touch any projects' do
          before { mock(repo).update_attribute(:subscribed, false) { false } }
        end
      end

      context "when unable to save project" do
        include_examples 'Github::Repo#(un)subscribe cannot touch any projects' do
          before { mock(project).save { false } }
        end
      end

      context "when unable to remove hook from github project" do
        include_examples 'Github::Repo#(un)subscribe cannot touch any projects' do
          before do
            mock(project).save                                   { true  }
            mock(user).remove_hook_from_github_project(anything) { false }
          end
        end
      end

      context "when unable to remove deploy key from github project" do
        include_examples 'Github::Repo#(un)subscribe cannot touch any projects' do
          before do
            mock(project).save                                         { true  }
            mock(user).remove_hook_from_github_project(anything)       { true  }
            mock(user).remove_deploy_key_from_github_project(anything) { false }
          end
        end
      end
    end

  end

  context "#subscribe" do
    let(:user)    { repo.user }
    subject { repo.subscribe }

    context "successfuly" do

      context "when associated project exists" do
        let!(:project) { create :project, :github, name: repo.full_name }
        before do
          mock(user).add_deploy_key_to_github_project(project) { true }
          mock(user).add_hook_to_github_project(project) { true }
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
          mock(user).add_deploy_key_to_github_project(anything) { true }
          mock(user).add_hook_to_github_project(anything)       { true }
        end

        it "should create a new github project" do
          expect{ subject }.to change(Project.github, :count).by(1)
        end

        it "should change 'subscribed' to true" do
          expect{ subject }.to change(repo, :subscribed).to(true)
        end

        context "created github project" do
          subject { Project.github.last }
          before  { repo.subscribe }
          its(:name)        { should eq repo.full_name   }
          its(:http_url)    { should eq repo.html_url    }
          its(:clone_url)   { should eq repo.ssh_url     }
          its(:description) { should eq repo.description }
        end
      end
    end

    context "fail" do

      context "when unable to update attribute 'subscribed'" do
        include_examples 'Github::Repo#(un)subscribe cannot touch any projects' do
          before { mock(repo).update_attribute(:subscribed, true) { false } }
        end
      end

      context "when unable to create project" do
        include_examples 'Github::Repo#(un)subscribe cannot touch any projects' do
          before { mock(repo).html_url { nil } }
        end
      end

      context "when unable to add deploy key to github project" do
        include_examples 'Github::Repo#(un)subscribe cannot touch any projects' do
          before { mock(user).add_deploy_key_to_github_project(anything) { false } }
        end
      end

      context "when unable to add hook to github project" do
        include_examples 'Github::Repo#(un)subscribe cannot touch any projects' do
          before do
            mock(user).add_deploy_key_to_github_project(anything) { true  }
            mock(user).add_hook_to_github_project(anything)       { false }
          end
        end
      end

    end
  end

  context "#as_json" do
    subject { repo.as_json }
    it { should eq({
      id:          repo.id,
      full_name:   repo.full_name,
      html_url:    repo.html_url,
      subscribed:  repo.subscribed
    }) }
  end

  context "(github api)" do
    let(:user)  { User.new }
    let(:attrs) { {
      id:          123456,
      full_name:   "full name",
      private:     true,
      description: 'description'
    } }
    let(:rels) { {
      ssh: OpenStruct.new(href: "ssh url"),
      html: OpenStruct.new(href: "html url"),
    } }
    let(:org) { OpenStruct.new id: 1, login: 'org login' }

    before do
      stub(attrs).rels { rels }
    end

    context "fetch_for_organization" do
      let(:proxy) { OpenStruct.new }
      let(:repos) { described_class.fetch_for_organization user, org }
      let(:admin) { true }
      subject { repos }

      before do
        mock(proxy).organization_repositories(org) { [attrs] }
        mock(user).github { proxy }
        mock(attrs).permissions { OpenStruct.new admin: admin }
      end

      it { should have(1).item }

      context "builded repo" do
        subject { repos.first }

        it { should be_an_instance_of described_class }
        its(:organization_login) { should eq 'org login' }
        include_examples 'github repo common attributes'
      end

      context "reject repositories without admin access" do
        let(:admin) { false }
        it { should be_empty }
      end
    end

    context "fetch_for_user" do
      let(:proxy) { OpenStruct.new repositories: [attrs] }
      let(:repos) { described_class.fetch_for_user user }

      subject { repos }

      before do
        mock(user).github { proxy }
      end

      it { should have(1).item }

      context "builded repo" do
        subject { repos.first }

        it { should be_an_instance_of described_class }
        its(:organization_login) { should be_nil      }
        include_examples 'github repo common attributes'
      end
    end

    context "build_from_attributes" do
      let(:user)    { create :user }
      let(:options) { { } }
      let(:repo)    { described_class.build_from_attributes user, attrs, options }
      subject       { repo }

      context "when repo exists" do
        let(:user)     { create :user, email: 'new email' }
        let(:options)  { { user: user } }
        let!(:existed) {
          create :github_repo,
                 full_name: attrs[:full_name],
                 html_url: 'changed',
                 user: user
        }

        it { should eq repo                      }
        its(:id)         { should eq existed.id  }
        its(:persisted?) { should be             }
        include_examples 'github repo common attributes'
      end

      context "with :user option" do
        let(:options) { { user: user } }

        its(:organization_login) { should be_nil }
        its(:persisted?)         { should_not be }
        include_examples 'github repo common attributes'
      end

      context "with :organization option" do
        let(:options) { { organization: org } }

        its(:organization_login) { should eq 'org login' }
        its(:persisted?)         { should_not be         }
        include_examples 'github repo common attributes'
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

