require 'spec_helper'

describe Invoice do
  let(:invoice) { build :invoice }

  it "should be valid" do
    expect(invoice).to be_valid
  end
end
