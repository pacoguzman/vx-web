require 'spec_helper'

describe UserRepoSerializer do
  let(:user_repo)  { create :user_repo }
  let(:serializer) { described_class.new user_repo }

  context "as_json" do
    subject { serializer.as_json.keys }

    it { should eq [:id, :full_name, :html_url, :subscribed,
                    :disabled, :settings_url, :provider_title] }
  end

  context "disabled" do
    subject { serializer.disabled }
    context "when is not subscribed and have same name projects" do
      before do
        user_repo.update subscribed: false
        create :project, name: user_repo.full_name, user_repo: nil
      end
      it { should be(true) }
    end

    context "when is subscribed and have same name projects" do
      before do
        user_repo.update subscribed: true
        create :project, name: user_repo.full_name, user_repo: nil
      end
      it { should be(false) }
    end
  end

  context "subscribed" do
    subject { serializer.subscribed }

    context "when user_repo subscribed" do
      before do
        user_repo.update subscribed: true
      end
      it { should be(true) }
    end

    context "when user_repo project" do
      before do
        user_repo.update subscribed: false
        create :project, user_repo: user_repo
      end
      it { should be(true) }
    end

    context "when same name project" do
      before do
        user_repo.update subscribed: false
        create :project, user_repo: nil, name: user_repo.full_name
      end
      it { should be(true) }
    end

    context "when user_repo is not subscribed" do
      before do
        user_repo.update subscribed: false
      end
      it { should be(false) }
    end

  end
end
