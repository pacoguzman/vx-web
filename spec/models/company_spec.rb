require 'spec_helper'

describe Company do
  let(:company) { build :company }
  subject { company }

  it { should be_valid }
end
