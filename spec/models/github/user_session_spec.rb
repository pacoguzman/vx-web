require 'spec_helper'
require 'ostruct'

shared_examples 'cannot create any of github users or identiries' do
  it "cannot create any users" do
    expect {
      User.from_github auth
    }.to_not change(User, :count)
  end

  it "cannot create any identities" do
    expect {
      User.from_github auth
    }.to_not change(UserIdentity, :count)
  end

  it "should return nil" do
    expect(User.from_github auth).to be_nil
  end
end

shared_examples "cannot touch any projects on github when user is not githubber" do
  context "when user is not githubber" do
    before { stub(user).github { nil } }

    it "cannot touch any projects on github" do
      expect(subject).to be_nil
    end
  end
end

describe Github::UserSession do
  let(:user) { User.new }
  subject    { user     }

  context ".from_github" do
    let(:uid)   { 'uid'   }
    let(:email) { 'email' }
    let(:name)  { 'name'  }
    let(:auth)  { OpenStruct.new(
      uid:         uid,
      credentials: OpenStruct.new(token: 'token'),
      info:        OpenStruct.new(name:     name,
                                  email:    email,
                                  nickname: 'nickname')
    ) }
    subject     { User.from_github auth }

    context "when user exists" do
      let!(:identity) { create :user_identity, :github, uid: uid }

      it "cannot create any users and identities" do
        expect {
          User.from_github auth
        }.to_not change{ User.count + UserIdentity.count }
      end

      it { should eq identity.user }
    end

    context "when user does not exists" do

      context "created user" do
        its(:email)      { should eq 'email'   }
        its(:name)       { should eq 'name'    }
        its(:identities) { should have(1).item }

        context "github identity" do
          subject {
            User.from_github(auth).identities.find_by_provider(:github)
          }

          its(:uid)   { should eq 'uid'      }
          its(:token) { should eq 'token'    }
          its(:login) { should eq 'nickname' }
        end

        context "when email in auth is blank" do
          let(:email) { nil                          }
          subject     { User.from_github(auth).email }
          it { should eq 'githubuid@empty' }
        end
      end

      context "when fail to create user" do
        let(:name) { nil }
        include_examples 'cannot create any of github users or identiries'
      end

      context "when fail to create identity" do
        let(:uid)  { nil }
        include_examples 'cannot create any of github users or identiries'
      end

    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string(255)      not null
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

