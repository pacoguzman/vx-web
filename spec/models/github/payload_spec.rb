require 'spec_helper'

describe Github::Payload do
  let(:content) { read_json_fixture("github/push.json") }
  let(:payload) { described_class.new content }
  subject { payload }

  context "push" do
    let(:url)     { "https://github.com/evrone/ci-worker-test-repo/compare/b665f9023956...687753389908"  }

    its(:pull_request?)       { should be_false                                      }
    its(:pull_request_number) { should be_nil                                        }
    its(:head)                { should eq '84158c732ff1af3db9775a37a74ddc39f5c4078f' }
    its(:base)                { should eq 'b665f90239563c030f1b280a434b3d84daeda1bd' }
    its(:branch)              { should eq 'master'                                   }
    its(:branch_label)        { should eq 'master' }
    its(:url)                 { should eq url                                        }
  end

  context "pull_request" do
    let(:content) { read_json_fixture("github/pull_request.json")              }
    let(:url)     { "https://api.github.com/repos/evrone/cybergifts/pulls/177" }

    its(:pull_request?)       { should be_true }
    its(:pull_request_number) { should eq 177 }
    its(:head)                { should eq '84158c732ff1af3db9775a37a74ddc39f5c4078f' }
    its(:base)                { should eq 'a1ea1a6807ab8de87e0d685b7d5dcad0c081254e' }
    its(:branch)              { should eq 'test' }
    its(:branch_label)        { should eq 'dima-exe:test' }
    its(:url)                 { should eq url }
  end

  context "closed_pull_request?" do
    context "when state is closed" do
      let(:content) { read_json_fixture("github/closed_pull_request.json") }
      it { should be_true }
    end
  end

  context "ignore?" do
    context "when pull request" do
      let(:content) { read_json_fixture("github/pull_request.json") }
      it {  should be_false}

      context "and is closed" do
        let(:content) { read_json_fixture("github/closed_pull_request.json") }
        it { should be_true }
      end
    end

    context "when regular commit" do
      it { should be_false }

      context "and deleted branch" do
        before do
          mock(payload).head{ '0000000000000000000000000000000000000000' }
        end
        it { should be_true }
      end
    end
  end

  context "to_hash" do
    subject { payload.to_hash.keys }
    it { should eq [:pull_request, :pull_request_number, :head,
                    :base, :branch, :branch_label, :url] }
  end

end
