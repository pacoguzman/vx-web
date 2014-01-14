require 'spec_helper'

describe BuildFetcher do
  let(:project) { create :project }
  let(:params)  { read_json_fixture("github/push.json").merge(token: project.token) }
  let(:fetcher) { described_class.new params }

  subject { fetcher }

  context "just created" do
    its(:project) { should eq project }
    its(:payload) { should be }
    its(:task)    { should be }
    its(:source)  { should be }
    its(:matrix)  { should be }
  end

  context "#build" do
    subject { fetcher.build }

    it "should create build using payload" do
      expect{
        fetcher.build
      }.to change(project.builds, :count).by(1)

      expect(subject.sha).to eq '84158c732ff1af3db9775a37a74ddc39f5c4078f'
      expect(subject.branch).to eq 'master'
    end
  end

  context "#perform" do
    let(:user)     { create :user }
    let(:identity) { create :user_identity, :github, user: user }
    subject { fetcher.perform }

    before do
      fetcher.project.update! identity: identity if fetcher.project
    end

    context "success" do
      before do
        mock_commit_request
        mock_contents_request
      end

      it { should be }

      it "should craate project build" do
        expect {
          subject
        }.to change(project.builds, :count).by(1)
      end

      it "should assign commit to build" do
        subject
        expect(subject.author).to eq 'Dmitry Galinsky'
      end

      it "should assign source to build" do
        subject
        expect(subject.source.keys).to be_include("rvm")
      end

      it "should create jobs" do
        expect {
          subject
        }.to change(fetcher.build.jobs, :count).by(1)
        job = subject.jobs.first
        expect(job).to be
        expect(job.number).to eq 1
        expect(job.matrix).to eq({"rvm"=>"2.0.0"})
        expect(job.source).to be
      end

      it "should publish message to JobConsumer" do
        expect {
          subject
        }.to change(JobsConsumer.messages, :count).by(1)
      end
    end

    context "failed" do
      context "when fail to find project" do
        let(:params) { {} }

        it { should be_nil }
      end

      context "when ignore payload" do
        before do
          mock(fetcher.payload).ignore? { true }
        end
        it { should be_nil }
      end

      context "when fail to fetch source" do
        before do
          mock_not_found_contents_request
        end

        it "cannot create any builds" do
          expect {
            subject
          }.to_not change(project.builds, :count)
        end
      end

      context "when fail to fetch commit" do
        before do
          mock_contents_request
          mock_not_found_commit_request
        end

        it "cannot create any builds" do
          expect {
            subject
          }.to_not change(project.builds, :count)
        end
      end

      context "when jobs is empty" do
        before do
          mock_contents_request
          mock_commit_request
          mock(fetcher).matrix { [] }
        end

        it "cannot create any builds" do
          expect {
            subject
          }.to_not change(project.builds, :count)
        end
      end
    end

  end

  context "(github)" do
    let(:user)     { create :user }
    let(:identity) { create :user_identity, :github, user: user }
    let(:project)  { create :project }
    before do
      project.update! identity: identity
      stub(fetcher).project { project }
    end

    context "just created" do
      its(:github) { should be }
    end

    context "#fetch_commit_from_github" do
      subject { fetcher.fetch_commit_from_github }

      it "should be success" do
        mock_commit_request
        expect(subject.sha).to     eq '84158c732ff1af3db9775a37a74ddc39f5c4078f'
        expect(subject.message).to eq "Update Rakefile"
        expect(subject.author).to  eq "Dmitry Galinsky"
        expect(subject.author_email).to_not be_blank
        expect(subject.http_url).to_not be_blank
      end

      context "when commit not found" do
        it "should be nil" do
          mock_not_found_commit_request
          expect(subject).to be_nil
        end
      end
    end

    context "#fetch_configuration_from_github" do
      subject { fetcher.fetch_configuration_from_github }

      it "should be success" do
        mock_contents_request
        expect(subject).to_not be_blank
      end

      context "when not found" do
        it "should be nil" do
          mock_not_found_contents_request
          expect(subject).to be_nil
        end
      end
    end
  end

  def mock_commit_request
    commit = read_fixture("github/commit.json")
    stub_request(:get, "https://api.github.com/repos/ci-worker-test-repo/commits/84158c732ff1af3db9775a37a74ddc39f5c4078f").
       with(:headers => {'Authorization'=>'token MyString'}).
       to_return(:status => 200, :body => commit, headers: {'Content-Type' => 'application/json'})
  end

  def mock_not_found_commit_request
    stub_request(:get, "https://api.github.com/repos/ci-worker-test-repo/commits/84158c732ff1af3db9775a37a74ddc39f5c4078f").
       with(:headers => {'Authorization'=>'token MyString'}).
       to_return(:status => 404, :body => "{}", headers: {'Content-Type' => 'application/json'})
  end

  def mock_contents_request
    contents = read_fixture("github/contents.json")
    stub_request(:get, "https://api.github.com/repos/ci-worker-test-repo/contents/.travis.yml?ref=84158c732ff1af3db9775a37a74ddc39f5c4078f").
       with(:headers => {'Authorization'=>'token MyString'}).
       to_return(:status => 200, :body => contents, headers: {'Content-Type' => 'application/json'})
  end

  def mock_not_found_contents_request
    stub_request(:get, "https://api.github.com/repos/ci-worker-test-repo/contents/.travis.yml?ref=84158c732ff1af3db9775a37a74ddc39f5c4078f").
       with(:headers => {'Authorization'=>'token MyString'}).
       to_return(:status => 404, :body => "{}", headers: {'Content-Type' => 'application/json'})
  end
end
