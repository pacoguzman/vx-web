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

  context ".find_job_for_status_message" do
    let(:msg) { Evrone::CI::Message::JobStatus.test_message job_id: job_id }
    let(:job) { create :job }
    subject { described_class.find_job_for_status_message job.build, msg }

    context "when job exists" do
      let(:job_id) { job.number }
      it { should eq job }
    end

    context "when job does not exists" do
      let(:job_id) { job.number + 1 }
      it { should be_nil }
    end
  end

  context "create_job_for_status_message" do
    let(:b) { create :build }
    let(:msg) { Evrone::CI::Message::JobStatus.test_message }
    subject { described_class.create_job_for_status_message b, msg }

    it { should be }
    its(:number) { should eq 2 }
    its(:matrix) { should eq(:env=>"FOO = 1", :rvm=>"1.9.3") }
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

