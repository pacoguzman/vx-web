require "spec_helper"

describe BuildsMailer do
  let(:b)    { create(:build, status: 3, number: 1, http_url: "http://github.com/vexor/vx-test-repo") }
  let(:sub)  { create :project_subscription, project: b.project  }
  let(:mail) { described_class.status_email(b, sub) }

  subject { mail }

  its(:subject) { should eq '[Passed] ci-worker-test-repo#1 (MyString - 91405d6c1)' }
  its(:to)      { should eq [sub.user.email] }

  context "text body" do
    subject { mail.text_part }

    its(:body) { should match(/##{b.number}/) }
    its(:body) { should match(/#{ b.project }/) }
    its(:body) { should match(/#{ b.author }/) }
    its(:body) { should match(/#{ b.short_sha }/) }
    its(:body) { should match(/#{ b.message }/) }
    its(:body) { should match(/#{ b.http_url }/) }
  end

  context "html body" do
    subject { mail.html_part }

    its(:body) { should match(/##{b.number}/) }
    its(:body) { should match(/#{ b.project }/) }
    its(:body) { should match(/#{ b.author }/) }
    its(:body) { should match(/#{ b.short_sha }/) }
    its(:body) { should match(/#{ b.message }/) }
    its(:body) { should match(/#{ b.http_url }/) }

    it "header includes json-ld info" do
      json = extract_jsonld(subject.body)

      json["@context"].should eq("http://schema.org")
      json["@type"].should eq("EmailMessage")
      json["action"]["@type"].should eq("ViewAction")
      json["action"]["url"].should eq(b.public_url)
      json["action"]["name"].should eq("View build")
      json["description"].should eq("View the '#{b.project}' build online")
    end
  end

  def extract_jsonld(body)
    JSON.parse Nokogiri.parse(body.raw_source).at_css('body script[type="application/ld+json"]').content
  end
end
