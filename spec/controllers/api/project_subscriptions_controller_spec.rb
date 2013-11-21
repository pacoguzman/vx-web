require 'spec_helper'

describe Api::ProjectSubscriptionsController do
  let(:user)    { create :user }
  let(:project) { create :project }

  subject { response }

  before do
    project
    session[:user_id] = user.id
  end

  context "POST /create" do
    before { post :create, project_id: project.id, format: :json }

    it { should be_success }
    its(:body) { should_not be_blank }
  end

  context "DELETE /destroy" do
    before { delete :destroy, project_id: project.id, format: :json }

    it { should be_success }
    its(:body) { should be_blank }
  end

end
