require 'spec_helper'

describe Github::Organization do
  let(:user) { User.new }
  let(:org) { described_class.new 1, 'login', user, nil }

  context "(github api)" do

    context "fetch" do
      let(:attrs) { {
        'id'    => 1,
        'login' => 'login'
      } }
      let(:proxy) { OpenStruct.new organizations: [attrs] }
      let(:repos) { 'repos' }
      subject { described_class.fetch user }

      before do
        mock(user).github { proxy }
        mock(Github::Repo).fetch_for_organization(anything) { repos }
      end

      it { should have(1).item }

      context "builded organization" do
        subject { described_class.fetch(user).first }

        its(:user)         { should eq user  }
        its(:repositories) { should eq repos }
      end

      context "reject organizations with empty repositories" do
        let(:repos) { [] }
        it { should be_empty }
      end

    end

  end
end
