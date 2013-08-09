require 'spec_helper'

describe Github::Payload do
  subject { described_class.new content }

  context "push" do
    let(:content) { read_json_fixture("github/push.json") }
    let(:url)     { "https://github.com/evrone/ci-worker-test-repo/compare/b665f9023956...687753389908"  }

    its(:pull_request?)       { should be_false                                      }
    its(:pull_request_number) { should be_nil                                        }
    its(:head)                { should eq '687753389908e70801dd4ff5448be908642055c6' }
    its(:base)                { should eq 'b665f90239563c030f1b280a434b3d84daeda1bd' }
    its(:branch)              { should eq 'master'                                   }
    its(:url)                 { should eq url                                        }
  end

  context "pull_request" do
    let(:content) { read_json_fixture("github/pull_request.json")              }
    let(:url)     { "https://api.github.com/repos/evrone/cybergifts/pulls/177" }

    its(:pull_request?)       { should be_true                                       }
    its(:pull_request_number) { should eq 177                                        }
    its(:head)                { should eq 'ca0bf451814a7ff90bc9694153189c6fa3bad112' }
    its(:base)                { should eq 'a1ea1a6807ab8de87e0d685b7d5dcad0c081254e' }
    its(:branch)              { should eq '260-feedback-test'                        }
    its(:url)                 { should eq url                                        }
  end

end
