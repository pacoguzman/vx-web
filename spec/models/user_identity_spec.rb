require 'spec_helper'

describe UserIdentity do
  let(:identity) { build :user_identity }

  context ".find_by_provider" do
    subject { described_class.find_by_provider "github" }
    before { identity.save! }

    it "should find the identity by provider name" do
      expect(subject).to eq identity
    end
  end

  context ".provider?" do
    before { identity.save! }

    it "should be true if provider exists" do
      expect(described_class.provider? "github").to be(true)
    end

    it "should be false unless provider" do
      expect(described_class.provider? "not-exists").to be(false)
    end
  end

  context "#sc" do
    subject { identity.sc }

    context "for github" do
      before do
        identity.provider = 'github'
      end
      it { should be_an_instance_of(Vx::ServiceConnector::Github) }
      its(:login)        { should eq identity.login }
      its(:access_token) { should eq identity.token }
    end

    context "for gitlab" do
      before do
        identity.provider = 'gitlab'
        identity.version  = '6.4.3'
      end
      it { should be_an_instance_of(Vx::ServiceConnector::GitlabV6) }
      its(:endpoint)      { should eq identity.url }
      its(:private_token) { should eq identity.token }
    end
  end

  context "ignored?" do
    subject { identity.ignored? }

    it "should be false when gitlab" do
      id = create :user_identity, :github
      expect(id).to_not be_ignored
    end

    it "should be false when gitlab v6" do
      id = create :user_identity, :gitlab, version: '6.4.3'
      expect(id).to_not be_ignored
    end

    it "should be false when gitlab v5" do
      id = create :user_identity, :gitlab, version: '5.4.3'
      expect(id).to be_ignored
    end
  end
end

# == Schema Information
#
# Table name: user_identities
#
#  provider   :string(255)      not null
#  token      :string(255)      not null
#  uid        :string(255)      not null
#  login      :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  url        :string(255)      not null
#  version    :string(255)
#  user_id    :uuid             not null
#  id         :uuid             not null, primary key
#

