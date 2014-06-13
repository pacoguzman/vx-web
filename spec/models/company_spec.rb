require 'spec_helper'

describe Company do
  let(:company) { build :company }
  subject { company }

  it { should be_valid }
end

# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

