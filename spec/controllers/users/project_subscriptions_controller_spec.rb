require 'spec_helper'

describe Users::ProjectSubscriptionsController do
  subject { response }

  it "should sucessfuly unsubscribe user from project" do
    project = create(:project)
    subscription = create(:project_subscription, project: project)
    subscription.update subscribe: true

    get :unsubscribe, project_id: project.id, id: subscription.id
    should be_success

    expect(subscription.reload).to_not be_subscribe
  end

  it "should be not found if project does not exists" do
    get :unsubscribe, project_id: uuid_for(1), id: uuid_for(1)
    should be_not_found
  end

  it "should be not found if subscription does not exists" do
    project = create(:project)
    get :unsubscribe, project_id: project.id, id: uuid_for(1)
    should be_not_found
  end

end
