require 'spec_helper'

describe Api::StatusController do
  subject { response }

  before do
    b = create :build
    num = 0
    3.times { create :job, status: "initialized", build: b, number: num += 1 }
    5.times { create :job, status: "started",     build: b, number: num += 1 }
    1.times { create :job, status: "passed",      build: b, number: num += 1 }
  end

  context "GET /status/jobs" do
    before { get :show, id: "jobs" }
    it { should be_success }
    its(:content_type) { should eq 'application/json' }
    its(:body)         { should eq({initialized: 3, started: 5}.to_json) }
  end

end
