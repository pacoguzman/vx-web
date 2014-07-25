require 'spec_helper'

describe InvoiceSerializer do
  let(:object) { create :invoice }
  let(:serializer) { described_class.new object }

  it "should successfuly serialize" do
    expect(serializer.to_json).to be
  end
end
