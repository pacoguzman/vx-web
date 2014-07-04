require 'spec_helper'

describe JobLog do
  subject { described_class.new }


  context "default_scope" do
    subject { described_class.all }
    before { create :job_log }
    it { should have(1).item }
  end
end

# == Schema Information
#
# Table name: job_logs
#
#  id     :integer          not null, primary key
#  tm     :integer
#  data   :text
#  job_id :uuid             not null
#

