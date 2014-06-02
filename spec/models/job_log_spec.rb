require 'spec_helper'

describe JobLog do
  subject { described_class.new }


  context "default_scope" do
    subject { described_class.all }
    before { create :job_log }
    it { subject.size.should eq 1 }
  end
end

# == Schema Information
#
# Table name: job_logs
#
#  id     :integer          not null, primary key
#  job_id :integer
#  tm     :integer
#  data   :text
#

