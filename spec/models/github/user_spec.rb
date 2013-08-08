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

describe Github::User do
  let(:user) { User.new }
  subject    { user     }

  context "(projects on github)" do
    let(:project) { build :project, :github }
    let(:github)  { 'proxy'                 }

    context "add_deploy_key_to_github_project!" do

      context "when user is githubber" do
        before do
          project.generate_deploy_key
          mock(user).github { github }
          mock(github).add_deploy_key(project.name,
                                      project.deploy_key_name,
                                      project.public_deploy_key) {
                                        'success'
                                      }
        end

        it "should add deploy key to project on github" do
          expect(user.add_deploy_key_to_github_project! project).to eq 'success'
        end
      end

      context "when user is not githubber" do
        before { mock(user).github { nil } }

        it "cannot touch any projects on github" do
          expect(user.add_deploy_key_to_github_project! project).to be_nil
        end
      end

    end

    context "#add_hook_to_github_project!" do

      context "when user is githubber" do
        before do
          mock(user).github { github }
          mock(github).create_hook(project.name, 'web', {
            url:          project.hook_url,
            secret:       project.token,
            content_type: 'json'
          }, {
            events:       %w{ push pull_request }
          }) { 'success' }
        end

        it "should create hook on github for project" do
          expect(user.add_hook_to_github_project! project).to eq 'success'
        end
      end

      context "when user is not githubber" do
        before { mock(user).github { nil } }

        it "cannot touch any projects on github" do
          expect(user.add_hook_to_github_project! project ).to be_nil
        end
      end

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
      its(:login)       { should eq identity.login  }
      its(:oauth_token) { should eq identity.token  }
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

      it {  should eq identity.user }
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
