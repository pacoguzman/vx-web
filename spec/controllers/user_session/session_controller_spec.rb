require 'spec_helper'

describe UserSession::SessionController do
  subject { response }

  context "DELETE /destroy" do

    before do
      session[:user_id] = 1
    end

    it "should be redirected to /ui" do
      delete :destroy
      should redirect_to("/ui")
    end

    it "should remove user_id from session" do
      expect {
        delete :destroy
      }.to change{ session[:user_id] }.from(1).to(nil)
    end

    context "for json request" do
      it "should return json object with location" do
        delete :destroy, format: :json
        should be_success
        expect(response.body).to eq '{"location":"/ui"}'
      end
    end

  end
end
