require 'spec_helper'
require 'ostruct'

shared_examples 'cannot create any of github users or identiries' do
  it "cannot create any users" do
    expect {
      User.from_github auth
    }.to_not change(User, :count)
  end

  it "cannot create any identities" do
    expect {
      User.from_github auth
    }.to_not change(UserIdentity, :count)
  end

  it "should return nil" do
    expect(User.from_github auth).to be_nil
  end
end

shared_examples "cannot touch any projects on github when user is not githubber" do
  context "when user is not githubber" do
    before { stub(user).github { nil } }

    it "cannot touch any projects on github" do
      expect(subject).to be_nil
    end
  end
end

describe Github::User do
  let(:user) { User.new }
  subject    { user     }

  context "(projects on github)" do
    let(:project) { build :project, :github }
    let(:github)  { 'proxy'                 }

    context "#remove_deploy_key_from_github_project" do
      let(:identity) { create :user_identity, :github, user: user }
      let(:user)     { create :user }
      subject { user.remove_deploy_key_from_github_project project }

      before do
        user.identities << identity
        mock_keys_request
        mock_delete_key_request
        stub(project).deploy_key_name { 'octocat@octomac' }
      end

      it "should be success" do
        expect(subject).to be
        expect(@keys).to have_been_requested
        expect(@delete_key).to have_been_requested
      end

      context "when key not found" do
        before do
          mock(project).deploy_key_name { 'not found' }
        end

        it "cannot delete any keys" do
          expect(subject).to be
          expect(@keys).to have_been_requested
          expect(@delete_key).to_not have_been_requested
        end
      end

      def mock_keys_request
        @keys = stub_request(:get, "https://api.github.com/repos/ci-worker-test-repo/keys?per_page=100").
          with(:headers => {'Authorization'=>'token MyString'}).
          to_return(:status => 200, :body => read_fixture("github/keys.json"), :headers => {'Content-Type'=>"application/json"})
      end

      def mock_delete_key_request
        @delete_key = stub_request(:delete, "https://api.github.com/repos/ci-worker-test-repo/keys/1").
          with(:headers => {'Authorization'=>'token MyString'}).
          to_return(:status => 204)
      end
    end

    context "#remove_hook_from_github_project" do
      let(:identity) { create :user_identity, :github, user: user }
      let(:user)     { create :user }
      subject { user.remove_hook_from_github_project project }

      before do
        user.identities << identity
        mock_hooks_request
        mock_delete_hook_request
        stub(Rails.configuration.x).hostname { 'ci.evrone.dev' }
      end

      it "should be success" do
        expect(subject).to be
        expect(@hooks).to have_been_requested
        expect(@delete_hook).to have_been_requested
      end

      context "when hook not found" do
        before do
          stub(Rails.configuration.x).hostname { 'not found' }
        end

        it "cannot delete any hooks" do
          expect(subject).to be
          expect(@hooks).to have_been_requested
          expect(@delete_hook).to_not have_been_requested
        end
      end

      def mock_hooks_request
        @hooks = stub_request(:get, "https://api.github.com/repos/ci-worker-test-repo/hooks?per_page=100").
          with(:headers => {'Authorization'=>'token MyString'}).
          to_return(:status => 200, :body => read_fixture("github/hooks.json"),
                    :headers => {'Content-Type' => "application/json"})
      end

      def mock_delete_hook_request
        @delete_hook = stub_request(:delete, "https://api.github.com/repos/ci-worker-test-repo/hooks/1347091").
          with(:headers => {'Authorization'=>'token MyString'}).
          to_return(:status => 204)
      end
    end

    context "#add_deploy_key_to_github_project" do
      subject { user.add_deploy_key_to_github_project project }

      context "when user is githubber" do
        before do
          project.generate_deploy_key
          mock(user).github.twice { github }
          mock(github).deploy_keys(anything) { [] }
          mock(github).add_deploy_key(project.name,
                                      project.deploy_key_name,
                                      project.public_deploy_key) {
                                        'success'
                                      }
        end

        it "should add deploy key to project on github" do
          expect(subject).to eq 'success'
        end
      end
      include_examples "cannot touch any projects on github when user is not githubber"
    end

    context "#add_hook_to_github_project" do
      subject { user.add_hook_to_github_project project }

      context "when user is githubber" do
        before do
          mock(user).github.twice { github }
          mock(github).hooks(anything) { [] }
          mock(github).create_hook(project.name, 'web', {
            url:          project.hook_url,
            secret:       project.token,
            content_type: 'json'
          }, {
            events:       %w{ push pull_request }
          }) { 'success' }
        end

        it "should create hook on github for project" do
          expect(subject).to eq 'success'
        end
      end

      include_examples "cannot touch any projects on github when user is not githubber"

    end
  end

  context "#sync_github_repos!" do
    let(:user)      { create :user                                      }
    let(:org)       { OpenStruct.new login: 'login'                     }
    let(:user_repo) { build :github_repo, user: user, full_name: "user" }
    let(:org_repo)  { build :github_repo, user: user, full_name: "org"  }
    subject { user.sync_github_repos! }

    before do
      mock(user).github_organizations { [org] }
      mock(Github::Repo).fetch_for_user(user) { [org_repo] }
      mock(Github::Repo).fetch_for_organization(user, org.login) { [user_repo] }
    end

    it { should eq 2 }

    it "should destroy any not synced repos" do
      repo = create :github_repo, user: user, full_name: "outdated"
      user.sync_github_repos!
      expect(Github::Repo.exists? repo.id).to be_false
    end
  end

  context "#github_organizations" do
    subject { user.github_organizations }

    context "when user is githubber" do
      before do
        mock(user).github.mock!.organizations { 'organizations' }
      end

      it { should eq 'organizations' }
    end

    context "when user is not githubber" do
      before { mock(user).github { nil } }
      it { should eq ([]) }
    end
  end

  context "#github" do
    context "when user hasnt any github identties" do
      subject { user.github }

      it { should be_nil }
    end

    context "should create Octokit::Client" do
      let(:identity) { create :user_identity, :github }
      subject { identity.user.github }

      it { should be_an_instance_of Octokit::Client }
      its(:login)        { should eq identity.login  }
      its(:access_token) { should eq identity.token  }
    end
  end

  context "#github?" do
    context "when user has any github identities" do
      let(:identity) { create :user_identity, :github }
      subject { identity.user.github? }

      it { should be_true }
    end

    context "when user hasnt any github identities" do
      subject { user.github? }

      it { should be_false }
    end
  end

  context ".from_github" do
    let(:uid)   { 'uid'   }
    let(:email) { 'email' }
    let(:name)  { 'name'  }
    let(:auth)  { OpenStruct.new(
      uid:         uid,
      credentials: OpenStruct.new(token: 'token'),
      info:        OpenStruct.new(name:     name,
                                  email:    email,
                                  nickname: 'nickname')
    ) }
    subject     { User.from_github auth }

    context "when user exists" do
      let!(:identity) { create :user_identity, :github, uid: uid }

      it "cannot create any users and identities" do
        expect {
          User.from_github auth
        }.to_not change{ User.count + UserIdentity.count }
      end

      it { should eq identity.user }
    end

    context "when user does not exists" do

      context "created user" do
        its(:email)      { should eq 'email'   }
        its(:name)       { should eq 'name'    }
        its(:identities) { should have(1).item }

        context "github identity" do
          subject {
            User.from_github(auth).identities.find_by_provider(:github)
          }

          its(:uid)   { should eq 'uid'      }
          its(:token) { should eq 'token'    }
          its(:login) { should eq 'nickname' }
        end

        context "when email in auth is blank" do
          let(:email) { nil                          }
          subject     { User.from_github(auth).email }
          it { should eq 'githubuid@empty' }
        end
      end

      context "when fail to create user" do
        let(:name) { nil }
        include_examples 'cannot create any of github users or identiries'
      end

      context "when fail to create identity" do
        let(:uid)  { nil }
        include_examples 'cannot create any of github users or identiries'
      end

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

