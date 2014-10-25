require 'spec_helper'

describe Users::SignupController do
  let(:auth_params) { {
    "credentials" => {
      "token" => "token"
    },
    "info" => {
      "name"    => "name",
      "email"   => "user@example.com",
      "nickname"=> "nickname"
    },
    "provider" => "github",
    "uid"      => "uid"
  } }
  let(:auth_hash) {
    OmniAuth::AuthHash.new(auth_params)
  }

  subject { response }

  context "GET /show" do
    before { get :show }
    it { should be_success }

    include_examples "when signup disabled" do
      let(:req) { get :show }
    end
  end

  context "GET /new" do

    context "successfuly" do
      before do
        session[:signup_omniauth] = auth_hash
        get :new
      end

      it { should be_success }
      context "@signup" do
        subject { assigns(:signup) }
        its(:company_name) { should eq 'nickname' }
        its(:email)        { should eq 'user@example.com' }
        it { should_not be_user_exists }
      end
    end

    context "when user with same identity exists" do
      before do
        user = create :user
        create :user_identity, user: user, provider: "github", uid: "uid"
        session[:signup_omniauth] = auth_hash
        get :new
      end

      it { should be_success }
      context "@signup" do
        subject { assigns(:signup) }
        it { should be_user_exists }
      end
    end

    context "when signup_omniauth key does not exists in session" do
      before do
        session[:signup_omniauth] = nil
        get :new
      end
      it { should redirect_to("/users/signup") }
    end

    include_examples "when signup disabled" do
      let(:req) { get :new }
    end
  end

  context "POST /create" do
    let(:email)        { 'email' }
    let(:company_name) { 'name' }
    let(:user)         { User.find_by(email: email) }
    let(:company)      { Company.find_by(name: company_name) }

    context "successfuly" do
      before do
        post_create
      end

      it { should redirect_to("/ui") }

      it "should create user" do
        expect(user).to be
      end

      it "should create company" do
        expect(company).to be
        expect(user.default_company).to eq company
        expect(user).to be_admin(company)
      end

      it "should create identity for user" do
        expect(user.identities.where(provider: "github").size).to eq(1)
      end

      it "should remove key signup_omniauth from session" do
        expect(session).to_not have_key(:signup_omniauth)
      end

      it "should authorize user" do
        expect(session[:user_id]).to eq user.id
      end
    end

    context "when user with same email exists" do
      before do
        create :user, email: email
        post_create
      end

      it { should_not be_success }
      it { should render_template("create") }

      it "cannot create company" do
        expect(company).to be_nil
      end

      it "cannot create identity for user" do
        expect(user.identities).to be_empty
      end

      it "user should have error on email" do
        expect(assigns(:signup).errors).to eq (
          ["User Email has already been taken"]
        )
      end

      it "should not remove key signup_omniauth from session" do
        expect(session).to have_key(:signup_omniauth)
      end

      it "should not authorize user" do
        expect(session).to_not have_key(:user_id)
      end
    end

    context "when company with same name exists" do
      before do
        create :company, name: company_name
        post_create
      end

      it { should_not be_success }
      it { should render_template("create") }

      it "cannot create user" do
        expect(user).to be_nil
      end

      it "user should have error on company name" do
        expect(assigns(:signup).errors).to eq (
          ["Company Name has already been taken"]
        )
      end

      it "should not remove key signup_omniauth from session" do
        expect(session).to have_key(:signup_omniauth)
      end

      it "should not authorize user" do
        expect(session).to_not have_key(:user_id)
      end
    end

    context "when user with same identity exists" do
      let!(:user) { create(:user) }

      before do
        create :user_identity, uid: "uid", user: user
        post_create
      end

      it { should redirect_to("/ui") }

      it "cannot update user email" do
        expect(user).to be
        expect(user.email).to_not eq 'email'
      end

      it "should create company" do
        expect(company).to be
        expect(user.default_company).to eq company
      end

      it "should keep identity for user" do
        expect(user.identities.size).to eq(1)
      end

      it "should remove key signup_omniauth from session" do
        expect(session).to_not have_key(:signup_omniauth)
      end

      it "should authorize user" do
        expect(session[:user_id]).to eq user.id
      end
    end

    context "when user with same identity exists and already in company" do
      let!(:user) { create(:user) }

      before do
        company = create :company, id: nil
        create :user_identity, uid: "uid", user: user
        user.add_to_company(company)
        post_create
      end

      it { should redirect_to("/ui") }

      it "cannot update user email" do
        expect(user).to be
        expect(user.email).to_not eq 'email'
      end

      it "should create company" do
        expect(company).to be
        expect(user.default_company).to eq company
        expect(user.companies.size).to eq(2)
      end

      it "should keep identity for user" do
        expect(user.identities.size).to eq(1)
      end

      it "should remove key signup_omniauth from session" do
        expect(session).to_not have_key(:signup_omniauth)
      end

      it "should authorize user" do
        expect(session[:user_id]).to eq user.id
      end
    end

    context "when signup_omniauth key does not exists in session" do
      before { post_create session: false }
      it { should redirect_to("/users/signup") }
    end

    include_examples "when signup disabled" do
      let(:req) { get :new }
    end

    def post_create(options = {})
      session[:signup_omniauth] = auth_hash if options[:session] != false
      post :create, email: email, company: company_name
    end
  end
end
