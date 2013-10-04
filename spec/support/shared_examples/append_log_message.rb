require 'evrone/ci/message'

shared_examples "AppendLogMessage" do
  let(:fkey) { collection.proxy_association.reflection.foreign_key }
  let(:fkey_val) { collection.proxy_association.owner.id }
  let(:message) {
    OpenStruct.new tm: 1, tm_usec: 2, log: "log"
  }
  subject { collection.append_log_message message }

  it { should be }

  its(:tm)      { should eq 1 }
  its(:tm_usec) { should eq 0 }
  its(:data)    { should eq 'log' }
  it "should have foreign object" do
    expect(subject.public_send fkey).to eq fkey_val
  end
end
