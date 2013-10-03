require 'evrone/ci/message'

shared_examples "AppendLogMessage" do
  let(:logs) {
    (0..2).map do |i|
      "n#{i}"
    end.join("\n")
  }
  let(:msg) { new_message logs }
  context "when each line with '\\n'" do
    it "should create record for each line" do
      created, updated = nil
      expect{
        created, updated = subject.append_log_message msg
      }.to change(subject, :count).by(3)

      expect(created).to have(3).items
      expect(updated).to be_empty
    end
  end

  context "when last log with '\\n' exists" do
    it "should create record for each line" do
      expect {
        subject.append_log_message new_message("log\n")
      }.to change(subject, :count).by(1)

      created, updated = nil
      expect{
        created, updated = subject.append_log_message msg
      }.to change(subject, :count).by(3)

      expect(created).to have(3).items
      expect(updated).to be_empty
    end
  end

  context "when last log without '\\n' exists" do
    it "should update last log and create record for each line" do
      expect {
        subject.append_log_message new_message("log ")
      }.to change(subject, :count).by(1)

      created, updated = nil
      expect{
        created, updated = subject.append_log_message msg
      }.to change(subject, :count).by(2)

      expect(created).to have(2).items
      expect(updated).to have(1).item

      expect(updated.first.reload.data).to eq "log n0\n"
    end
  end

  def new_message(data)
    Evrone::CI::Message::JobLog.test_message log: data
  end
end
