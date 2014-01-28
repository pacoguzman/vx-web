require 'spec_helper'

describe Gitlab::User do
  let(:user) { User.new }
  subject { user }

  context ".gitlab_hosts" do
    let(:env) { {
      'GITLAB_URL'  => "http://gitlab0.exampl.com",
      'GITLAB_URL0' => "http://gitlab1.exampl.com",
      'GITLAB_URL1' => "http://gitlab2.exampl.com"
    } }
    subject { User.gitlab_hosts env }

    it { should eq env.values }
  end
end
