shared_examples "when signup disabled" do
  context "when signup disabled" do

    before(:each) do
      Rails.configuration.x.disable_signup = true
    end

    context "and no users" do
      it { should_not be_not_found }
    end

    context "and have any users" do
      before do
        create :user
        req
      end
      it { should be_not_found }
    end
  end
end
