require 'spec_helper'

describe Github::Repo do

  context "(github api)" do
    let(:user)  { User.new }
    let(:attrs) { {
      "full_name"   => "full name",
      "private"     => true,
      "ssh_url"     => "ssh url",
      "html_url"    => "html url"
    } }
    let(:org) { Github::Organization.new 1, 'org login', user, nil }

    context "fetch_for_organization" do
      let(:proxy) { OpenStruct.new }
      let(:repos) { described_class.fetch_for_organization org }
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
        its(:full_name)          { should eq 'full name' }
        its(:is_private)         { should eq true        }
        its(:ssh_url)            { should eq 'ssh url'   }
        its(:html_url)           { should eq 'html url'  }
        its(:user)               { should eq user        }
        its(:organization_login) { should eq 'org login' }
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
        its(:full_name)          { should eq 'full name' }
        its(:is_private)         { should eq true        }
        its(:ssh_url)            { should eq 'ssh url'   }
        its(:html_url)           { should eq 'html url'  }
        its(:user)               { should eq user        }
        its(:organization_login) { should be_nil         }
      end
    end

    context "build_from_attributes" do
      let(:options) { {} }
      let(:repos) { described_class.build_from_attributes attrs, options }
      subject { repos }

      context "with :user option" do
        let(:options) { { user: user } }

        its(:full_name)          { should eq 'full name' }
        its(:is_private)         { should eq true        }
        its(:ssh_url)            { should eq 'ssh url'   }
        its(:html_url)           { should eq 'html url'  }
        its(:user)               { should eq user        }
        its(:organization_login) { should be_nil         }
      end

      context "with :organization option" do
        let(:options) { { organization: org } }

        its(:full_name)          { should eq 'full name' }
        its(:is_private)         { should eq true        }
        its(:ssh_url)            { should eq 'ssh url'   }
        its(:html_url)           { should eq 'html url'  }
        its(:user)               { should eq user        }
        its(:organization_login) { should eq 'org login' }
      end

    end

  end

end
