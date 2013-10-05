require 'spec_helper'

describe JobLog do
  subject { described_class.new }

end

# == Schema Information
#
# Table name: job_logs
#
#  id      :integer          not null, primary key
#  job_id  :integer
#  tm      :integer
#  tm_usec :integer
#  data    :text
#

