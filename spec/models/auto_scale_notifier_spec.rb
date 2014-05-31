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
      create :job
      expect {
        notifier.notify
      }.to change(messages, :count).by(1)
      expect(messages.last).to eq(key: "rx.test", jobs: 1)
    end
  end
end
