require 'spec_helper'

describe BuildFetcher do
  let(:build)   { create :build }
  let(:fetcher) { described_class.new build }
  subject { fetcher }

  it { should be }

  context "just created" do
    its(:build)   { should eq build }
    its(:project) { should eq build.project }
  end

  context "(github)" do
    let(:user) { create :user }
    let(:identity) { create :user_identity, :github, user: user }
    before do
      build.project.update! identity: identity
    end

    context "just created" do
      its(:github) { should be }
    end

    context "#fetch_commit_from_github" do
      subject { fetcher.fetch_commit_from_github }
      before { mock_commit_request }

      it "should be success" do
        expect(subject.sha).to     eq '84158c732ff1af3db9775a37a74ddc39f5c4078f'
        expect(subject.message).to eq "Update Rakefile"
        expect(subject.author).to  eq "Dmitry Galinsky"
        expect(subject.author_email).to_not be_blank
      end
    end

    context "#create_perform_build_message_using_github" do
      subject { fetcher.create_perform_build_message_using_github }
      before { mock_commit_request }

      %w{ sha message author author_email }.each do |m|
        it "should update build #{m}" do
          expect{ subject }.to change{ build.reload.public_send(m) }
        end
      end
    end

    def mock_commit_request
      commit = read_fixture("github/commit.json")
      stub_request(:get, "https://api.github.com/repos/ci-worker-test-repo/commits/MyString").
         with(:headers => {'Authorization'=>'token MyString'}).
         to_return(:status => 200, :body => commit, headers: {'Content-Type' => 'application/json'})
    end
  end

end
