require 'spec_helper'

describe ProjectSubscription do
  let(:sub) { build :project_subscription }
  subject { sub }

  it { should be_valid }
end
