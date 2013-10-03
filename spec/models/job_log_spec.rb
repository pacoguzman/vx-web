require 'spec_helper'

describe JobLog do
  subject { described_class.new }

  it_should_behave_like "AppendLogMessage" do
    let(:job) { create :job }
    subject { job.logs }
  end
end
