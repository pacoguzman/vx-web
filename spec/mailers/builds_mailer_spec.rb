require "spec_helper"

describe BuildsMailer do
  let(:build) {
    create(:build,
      started_at: 3.minutes.ago,
      finished_at: 1.minute.ago,
      status: 3,
      http_url: "http://exmaple.com",
    )
  }
  let(:mail) { described_class.status_email(build, ['example@exaple.com']) }

  subject { mail }

  its(:subject) { should eq "[Passed] ci-worker-test-repo##{build.number} (MyString - MyString)" }
  its(:to)      { should eq ["example@exaple.com"] }
  its(:body)    { should match(/##{build.number}/) }
  its(:body)    { should match(/#{ build.project }/) }
  its(:body)    { should match(/#{ build.author }/) }
  its(:body)    { should match(/#{ build.short_sha }/) }
  its(:body)    { should match(/#{ build.message }/) }
  its(:body)    { should match(/#{ build.http_url }/) }
end
