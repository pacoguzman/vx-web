require 'spec_helper'

shared_examples 'github repo common attributes' do
  its(:full_name)   { should eq 'full name'   }
  its(:is_private)  { should eq true          }
  its(:ssh_url)     { should eq 'ssh url'     }
  its(:html_url)    { should eq 'html url'    }
  its(:user)        { should eq user          }
  its(:description) { should eq 'description' }
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
    before do
      repo.update_attribute :subscribed, true
    end

    it "should change 'subscribed' to false" do
      expect{
        repo.unsubscribe
      }.to change(repo, :subscribed).to(false)
    end
  end

  context "#subscribe" do

    it "should change 'subscribed' to true" do
      expect{
        repo.subscribe
      }.to change(repo, :subscribed).to(true)
    end

    context "when associated project exists" do
      let!(:project) { create :project, :github, name: repo.full_name }

      it "cannot touch any projects" do
        expect{
          repo.subscribe
        }.to_not change(Project, :count)
      end
    end

    context "when associated project does not exists" do

      it "should create a new github project" do
        expect{
          repo.subscribe
        }.to change(Project.github, :count).by(1)
      end

      context "created github project" do
        subject { Project.github.last }
        before { repo.subscribe }

        its(:name)        { should eq repo.full_name   }
        its(:http_url)    { should eq repo.html_url    }
        its(:clone_url)   { should eq repo.ssh_url     }
        its(:description) { should eq repo.description }
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
      "id"          => 123456,
      "full_name"   => "full name",
      "private"     => true,
      "ssh_url"     => "ssh url",
      "html_url"    => "html url",
      "description" => 'description'
    } }
    let(:org) { OpenStruct.new id: 1, login: 'org login' }

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
                 full_name: attrs['full_name'],
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
