require 'spec_helper'

describe AutoScaleNotifier do
  let(:notifier) { described_class }
  subject { notifier }

  it '.key' do
    expect(subject.key).to eq 'rx.test'
  end

  context ".notify" do
    let(:messages) { AutoScaleConsumer.messages }
    it "should be" do
      b = create :build
      create :job, status: 0, build: b, number: 1
      create :job, status: 2, build: b, number: 2
      expect {
        notifier.notify
      }.to change(messages, :count).by(1)
      expect(messages.last).to eq(key: "rx.test", jobs: 2)
    end
  end
end
