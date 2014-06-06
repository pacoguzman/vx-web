require 'spec_helper'

describe UserSession::GithubController do
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

      it "should redirect to /auth/failure" do
        sign_in
        should redirect_to("/auth/failure")
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

  context "GET /sign_up" do
    let!(:company) { create :company }
    let(:email)   { 'me@example.com' }

    context "when user in restricted organization" do
      before do
        Rails.configuration.x.github_restriction = ["foo", "github"]
        mock_user_orgs
      end
      it "should redirect to /ui" do
        sign_up
        should redirect_to("/ui")
      end

      it "should create user" do
        expect { sign_up }.to change(User, :count).by(1)
      end
    end

    context "when user is not in restricted organization" do
      before do
        Rails.configuration.x.github_restriction = ["foo", "bar"]
        mock_user_orgs
      end

      it "should redirect to /auth/failure" do
        sign_up
        should redirect_to("/auth/failure")
      end

      it "cannot create any users" do
        expect { sign_up }.to_not change(User, :count)
      end
    end

    context "authorization failed" do
      let(:auth_hash) { :invalid_credentials }

      it "should redirect to /auth/failure" do
        sign_up
        should redirect_to("/auth/failure")
      end

      it "cannot create any users" do
        expect { sign_up }.to_not change(User, :count)
      end
    end

    context "when user with same email exists" do
      let!(:user)    { create :user, email: email}
      let(:identity) { user.identities(true).find_by(provider: 'github') }

      it "should redirect to /ui" do
        sign_up
        should redirect_to("/ui")
      end

      it "cannot create any users" do
        expect { sign_up }.to_not change(User, :count)
      end

      it "should create identity" do
        sign_up
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
        sign_up
        should redirect_to("/ui")
      end

      it "cannot create any users" do
        expect { sign_up }.to_not change(User, :count)
      end

      it "cannot create any user_copanies" do
        expect { sign_up }.to_not change(UserCompany, :count)
      end
    end

    context "when user with same email and github identity exists" do
      let!(:user)     { create :user, email: email}
      let!(:identity) { create :user_identity, :github, user: user }

      it "should redirect to /ui" do
        sign_up
        should redirect_to("/ui")
      end

      it "cannot create any users" do
        expect { sign_up }.to_not change(User, :count)
      end

      it "cannot create any identities" do
        expect { sign_up }.to_not change(UserIdentity, :count)
      end
    end

    context "when company not found" do
      it "should redirect to /auth/failure" do
        expect {
          sign_up company: "not found"
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "successfuly" do
      let(:user)     { User.find_by(email: email) }
      let(:identity) { user && user.identities.find_by(provider: 'github') }

      before { sign_up }

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
    end

    def sign_up(o = {})
      request.env['omniauth.params'] = {
        'do'      => "sign_up",
        "email"   => o[:email] || "me@example.com",
        "company" => o[:company] || company.name
      }
      get :callback
    end

  end

  def mock_user_orgs
    stub_request(:get, "https://api.github.com/user/orgs").
      with(:headers => {'Accept'=>'application/vnd.github.beta+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'token token', 'User-Agent'=>'Octokit Ruby Gem 2.2.0'}).
      to_return(:status => 200, :body => read_fixture("github/orgs.json"), :headers => {'Content-Type' => 'application/json'})
  end

end
