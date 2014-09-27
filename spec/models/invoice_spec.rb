require 'spec_helper'

describe Invoice do
  let(:invoice) { build :invoice }

  it "should be valid" do
    expect(invoice).to be_valid
  end

  it "should format amount value" do
    invoice.amount = '123'
    expect(invoice.amount_string).to eq '1.23'
  end
end
