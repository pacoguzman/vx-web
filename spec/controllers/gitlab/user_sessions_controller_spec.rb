require 'spec_helper'

describe Gitlab::UserSessionsController do

  subject { response }

  context "GET /create" do
    let(:params) { {
      email:    "me@example.com",
      password: "password",
      host:     "example.com"
    } }
    let(:auth_response) { {
      id:            "1",
      name:          "name",
      private_token: 'token',
      email:         "me@example.com",
      username:      "username"
    } }

    before do
      Gitlab::UserSession.uris({ "GITLAB_URL" => "https://example.com" })
    end

    after do
      Gitlab::UserSession.uris({})
    end

    context "authorization failed" do
      before { mock_auth_fail_request }

      it { post_create ; should render_template("welcome/signin") }
      it "cannot create any users" do
        expect { post_create }.to_not change(User, :count)
      end

      it "should be fail" do
        post_create
        expect(response.status).to eq 422
      end
    end

    context "when user with same email and not have gitlab identity" do
      let!(:user) { create :user, email: "me@example.com" }
      let(:identity) { user.identities.find_by(url: "https://example.com", provider: "gitlab") }

      before { mock_auth_request }

      it { post_create ; should redirect_to("/") }

      it "cannot create any users" do
        expect { post_create }.to_not change(User, :count)
      end

      it "should create identity" do
        post_create
        expect(identity).to       be
        expect(identity.uid).to   eq '1'
        expect(identity.token).to eq 'token'
        expect(identity.login).to eq 'username'
        expect(identity.url).to   eq 'https://example.com'
      end
    end

    context "when user and identity exists" do
      let!(:user)     { create :user, email: "me@example.com" }
      let!(:identity) { create :user_identity, :gitlab, user: user, url: "https://example.com" }

      before { mock_auth_request }

      it { post_create ; should redirect_to("/") }

      it "cannot create any users" do
        expect { post_create }.to_not change(User, :count)
      end

      it "cannot create any identities" do
        expect { post_create }.to_not change(UserIdentity, :count)
      end
    end

    context "when user does not exists" do
      let(:user)     { User.find_by(email: "me@example.com") }
      let(:identity) { user && user.identities.find_by(provider: 'gitlab') }

      before do
        mock_auth_request
        post_create
      end

      it { should redirect_to("/") }

      it "should create user" do
        expect(user).to be
        expect(user.name).to eq 'name'
      end

      it "should create identity" do
        expect(identity).to       be
        expect(identity.uid).to   eq '1'
        expect(identity.token).to eq 'token'
        expect(identity.login).to eq 'username'
        expect(identity.url).to   eq 'https://example.com'
      end

      it "should store user_id into session" do
        expect(session[:user_id]).to eq user.id
      end
    end

  end

  def post_create
    post :create, gitlab_user_session: params
  end

  def mock_auth_request
    stub_request(:post, "https://example.com/api/v3/session.json").
      with(:body => "{\"email\":\"me@example.com\",\"password\":\"password\"}",
           :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json'}).
      to_return(:status => 201, :body => auth_response.to_json, headers: {'Content-Type' => 'application/json'})
  end

  def mock_auth_fail_request
    stub_request(:post, "https://example.com/api/v3/session.json").
      with(:body => "{\"email\":\"me@example.com\",\"password\":\"password\"}",
           :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json'}).
      to_return(:status => 401, :body => {message: "Forbidden"}.to_json, headers: {'Content-Type' => 'application/json'})
  end


end
