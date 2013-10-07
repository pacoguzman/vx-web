require 'spec_helper'

describe BuildFetcher do
  let(:fetcher) { described_class.new payload }
  subject { fetcher }

  context "(github)" do
    let(:payload) { Github::Payload.new read_json_fixture("github/push.json") }

    it { should be }
  end
end
