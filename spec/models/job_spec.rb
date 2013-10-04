require 'spec_helper'
require 'ostruct'

describe Job do
  let(:job) { Job.new }

  it_should_behave_like "AppendLogMessage" do
    let(:job)        { create :job }
    let(:collection) { job.logs }
  end

  context ".extract_matrix" do
    let(:msg) { OpenStruct.new matrix: ["env:FOO = 1", "rvm:1.9.3"] }
    let(:expected) { {
      env: "FOO = 1",
      rvm: "1.9.3"
    } }
    subject { described_class.extract_matrix msg }

    it { should eq expected }
  end

  context ".find_or_create_by_status_message" do
    let(:msg) { Evrone::CI::Message::JobStatus.test_message }
    subject { described_class.find_or_create_by_status_message msg }

    context "when build does not exists" do
      it { should be_nil }
    end

    context "successfuly created job" do
      let(:tm) { Time.parse 'Sat, 10 Aug 2013 12:26:44 UTC +00:00'  }
      let!(:build)      { create :build, id: msg.build_id         }
      its(:number)      { should eq 2                             }
      its(:started_at)  { should eq tm                            }
      its(:matrix)      { should eq(env: "FOO = 1", rvm: "1.9.3") }
    end

    context "when unable to crete job" do
      let!(:build) { create :build, id: msg.build_id }
      before do
        mock(msg).job_id.twice { nil }
      end
      it {  should be_nil }
    end

    context "when job exists" do
      let(:build) { create :build, id: msg.build_id }
      let(:job)   { create :job, build: build, number: msg.job_id }

      it { should eq job }
    end
  end
end

# == Schema Information
#
# Table name: jobs
#
#  id          :integer          not null, primary key
#  build_id    :integer          not null
#  number      :integer          not null
#  status      :integer          not null
#  matrix      :hstore
#  started_at  :datetime
#  finished_at :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

