require 'spec_helper'

describe Users::GithubController do
  let(:env) { {
    uid: "uid",
    info: {
      name:     "name",
      email:    "email",
      nickname: "nickname",
    },
    credentials: {
      token: "token"
    }
  } }
  let(:auth_hash) {
    OmniAuth::AuthHash.new(env.merge(provider: "github"))
  }

  subject { response }

  before do
    OmniAuth.config.mock_auth[:github] = auth_hash
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
  end

  context "GET /sign_in" do
    context "when user and identity exists" do
      let!(:user)     { create :user, email: "me@example.com" }
      let!(:identity) { create :user_identity, :github, user: user, url: "https://github.com" }

      it "should redirect to /ui" do
        sign_in
        should redirect_to("/ui")
      end

      it "cannot create any users" do
        expect { sign_in }.to_not change(User, :count)
      end

      it "cannot create any identities" do
        expect { sign_in }.to_not change(UserIdentity, :count)
      end
    end

    context "authorization failed" do
      let(:auth_hash) { :invalid_credentials }

      it "should redirect to /users/failure" do
        sign_in
        should redirect_to("/users/failure")
      end

      it "cannot create any users" do
        expect { sign_in }.to_not change(User, :count)
      end
    end

    def sign_in
      request.env['omniauth.params'] = { "do" => "sign_in" }
      get :callback
    end
  end

  context "GET /invite" do
    let(:email)    { 'me@example.com' }
    let!(:invite)  { create :invite, email: email }
    let!(:company) { create :company  }

    context "authorization failed" do
      let(:auth_hash) { :invalid_credentials }

      it "should redirect to /users/failure" do
        get_invite
        should redirect_to("/users/failure")
      end

      it "cannot create any users" do
        expect { get_invite }.to_not change(User, :count)
      end
    end

    context "when user with same email exists" do
      let!(:user)    { create :user, email: email}
      let(:identity) { user.identities(true).find_by(provider: 'github') }

      it "should redirect to /ui" do
        get_invite
        should redirect_to("/ui")
      end

      it "cannot create any users" do
        expect { get_invite }.to_not change(User, :count)
      end

      it "should create identity" do
        get_invite
        expect(identity).to       be
        expect(identity.uid).to   eq 'uid'
        expect(identity.token).to eq 'token'
        expect(identity.login).to eq 'nickname'
        expect(identity.url).to   be
      end
    end

    context "when user with same email exists and in same company" do
      let!(:user)    { create :user, email: email}

      before do
        user.companies << company
      end

      it "should redirect to /ui" do
        get_invite
        should redirect_to("/ui")
      end

      it "cannot create any users" do
        expect { get_invite }.to_not change(User, :count)
      end

      it "cannot create any user_copanies" do
        expect { get_invite }.to_not change(UserCompany, :count)
      end
    end

    context "when user with same email and github identity exists" do
      let!(:user)     { create :user, email: email}
      let!(:identity) { create :user_identity, :github, user: user }

      it "should redirect to /ui" do
        get_invite
        should redirect_to("/ui")
      end

      it "cannot create any users" do
        expect { get_invite }.to_not change(User, :count)
      end

      it "cannot create any identities" do
        expect { get_invite }.to_not change(UserIdentity, :count)
      end
    end

    context "when company not found" do
      it "should redirect to /users/failure" do
        get_invite company: "not found"
        should be_not_found
      end
    end

    context "when invite not found" do
      it "should redirect to /users/failure" do
        get_invite token: "not found"
        should be_not_found
      end
    end

    context "successfuly" do
      let(:user)     { User.find_by(email: email) }
      let(:identity) { user && user.identities.find_by(provider: 'github') }

      before { get_invite }

      it { should redirect_to("/ui") }

      it "should create user" do
        expect(user).to be
        expect(user.name).to eq 'name'
        expect(user.email).to eq email
      end

      it "should create identity" do
        expect(identity).to       be
        expect(identity.uid).to   eq 'uid'
        expect(identity.token).to eq 'token'
        expect(identity.login).to eq 'nickname'
        expect(identity.url).to   be
      end

      it "should put user to company" do
        expect(company.users).to be_include(user)
      end

      it "should store user_id into session" do
        expect(session[:user_id]).to eq user.id
      end

      it "should destroy invite" do
        expect{ invite.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    def get_invite(o = {})
      request.env['omniauth.params'] = {
        'do'      => "invite",
        "email"   => o[:email]   || "me@example.com",
        "token"   => o[:token]   || invite.token,
        "company" => o[:company] || company.name
      }
      get :callback
    end

  end

  context "GET /sign_up" do
    context "successfuly" do

      before do
        sign_up
      end

      it { should redirect_to("/users/signup/new") }

      it "should cretae signup_omniauth session key" do
        expect(session[:signup_omniauth]).to eq(
          "credentials" => {
            "token" => "token"
          },
          "info" => {
            "name"    => "name",
            "email"   => "email",
            "nickname"=> "nickname"
          },
          "provider" => "github",
          "uid"      => "uid"
        )
      end
    end

    def sign_up
      request.env['omniauth.params'] = { "do" => "sign_up" }
      get :callback
    end
  end

  def mock_user_orgs
    stub_request(:get, "https://api.github.com/user/orgs").
      with(:headers => {'Accept'=>'application/vnd.github.beta+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'token token', 'User-Agent'=>'Octokit Ruby Gem 2.2.0'}).
      to_return(:status => 200, :body => read_fixture("github/orgs.json"), :headers => {'Content-Type' => 'application/json'})
  end

end
