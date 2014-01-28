require 'spec_helper'

describe Github::UserSessionsController do

  subject { response }

  context "GET /create" do
    let(:env) { {
      uid: "uid",
      info: {
        name: "name",
        email: "me@example.com",
        nickname: "nickname",
      },
      credentials: {
        token: "token"
      }
    } }
    let(:auth_hash) {
      OmniAuth::AuthHash.new(env.merge(provider: "github"))
    }

    before do
      OmniAuth.config.mock_auth[:github] = auth_hash
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
    end

    context "when user in restricted organization" do
      before do
        Rails.configuration.x.github_restriction = ["foo", "github"]
        mock_user_orgs
      end
      it { get :create ; should redirect_to("/") }
      it "should create user" do
        expect { get :create }.to change(User, :count).by(1)
      end
    end

    context "when user is not in restricted organization" do
      before do
        Rails.configuration.x.github_restriction = ["foo", "bar"]
        mock_user_orgs
      end

      it { get :create ; should redirect_to("/auth/failure") }
      it "cannot create any users" do
        expect { get :create }.to_not change(User, :count)
      end
    end

    context "authorization failed" do
      let(:auth_hash) { :invalid_credentials }

      it { get :create ; should redirect_to("/auth/failure") }
      it "cannot create any users" do
        expect { get :create }.to_not change(User, :count)
      end
    end

    context "when user with same email and not have github identity" do
      let!(:user) { create :user, email: "me@example.com" }
      let(:identity) { user.identities.find_by(provider: "github", url: "https://github.com") }

      it { get :create ; should redirect_to("/") }

      it "cannot create any users" do
        expect { get :create }.to_not change(User, :count)
      end

      it "should create identity" do
        get :create
        expect(identity).to       be
        expect(identity.uid).to   eq 'uid'
        expect(identity.token).to eq 'token'
        expect(identity.login).to eq 'nickname'
        expect(identity.url).to   be
      end
    end

    context "when user and identity exists" do
      let!(:user)     { create :user, email: "me@example.com" }
      let!(:identity) { create :user_identity, :github, user: user, url: "https://github.com" }

      it { get :create ; should redirect_to("/") }

      it "cannot create any users" do
        expect { get :create }.to_not change(User, :count)
      end

      it "cannot create any identities" do
        expect { get :create }.to_not change(UserIdentity, :count)
      end
    end

    context "when user does not exists" do
      let(:user)     { User.find_by(email: "me@example.com") }
      let(:identity) { user && user.identities.find_by(provider: 'github') }

      before { get :create }

      it { should redirect_to("/") }

      it "should create user" do
        expect(user).to be
        expect(user.name).to eq 'name'
      end

      it "should create identity" do
        expect(identity).to       be
        expect(identity.uid).to   eq 'uid'
        expect(identity.token).to eq 'token'
        expect(identity.login).to eq 'nickname'
        expect(identity.url).to   be
      end

      it "should store user_id into session" do
        expect(session[:user_id]).to eq user.id
      end
    end

  end

  def mock_user_orgs
    stub_request(:get, "https://api.github.com/user/orgs").
      with(:headers => {'Accept'=>'application/vnd.github.beta+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'token token', 'User-Agent'=>'Octokit Ruby Gem 2.2.0'}).
      to_return(:status => 200, :body => read_fixture("github/orgs.json"), :headers => {'Content-Type' => 'application/json'})
  end

end
