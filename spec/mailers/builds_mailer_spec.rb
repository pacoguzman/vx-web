require "spec_helper"

describe BuildsMailer do
  let(:b)    { create(:build, status: 3) }
  let(:sub)  { create :project_subscription, project: b.project  }
  let(:mail) { described_class.status_email(b, sub) }

  subject { mail }

  its(:subject) { should eq '[Passed] ci-worker-test-repo#1 (MyString - 91405d6c1)' }
  its(:to)      { should eq [sub.user.email] }
  its(:body)    { should match(/#1/) }
  its(:body)    { should match(/#{ b.project }/) }
  its(:body)    { should match(/#{ b.author }/) }
  its(:body)    { should match(/#{ b.short_sha }/) }
  its(:body)    { should match(/#{ b.message }/) }
  its(:body)    { should match(/#{ b.http_url }/) }
end
