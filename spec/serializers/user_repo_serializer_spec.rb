require 'spec_helper'

describe UserRepoSerializer do
  let(:user_repo)  { create :user_repo }
  let(:serializer) { described_class.new user_repo }

  it "should find same_name_projects in object" do
    expect(described_class.new user_repo).to_not be_same_name_projects
    create :project, name: user_repo.full_name, company: user_repo.company
    expect(described_class.new user_repo).to be_same_name_projects
  end

  it "should find same_name_projects in scope" do
    dont_allow(user_repo).same_name_projects?

    struct = Struct.new(:same_name_projects)

    scope = struct.new([])
    expect(described_class.new user_repo, scope: scope).to_not be_same_name_projects

    scope = struct.new([OpenStruct.new(name: user_repo.full_name, id: 1)])
    expect(described_class.new user_repo, scope: scope).to be_same_name_projects
  end

  context "as_json" do
    subject { serializer.as_json.keys }

    it { should eq [:id, :full_name, :html_url, :subscribed,
                    :disabled, :settings_url, :provider_title,
                    :description, :project_id] }
  end

  context "disabled" do
    subject { serializer.disabled }
    context "when is not subscribed and have same name projects" do
      before do
        user_repo.update subscribed: false
        create :project, name: user_repo.full_name, user_repo: create(:user_repo, company: user_repo.company), company: user_repo.company
      end
      it { should be(true) }
    end

    context "when is subscribed and have same name projects" do
      before do
        user_repo.update subscribed: true
        create :project, name: user_repo.full_name, user_repo: create(:user_repo, company: user_repo.company), company: user_repo.company
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
        create :project, user_repo: user_repo, company: user_repo.company
      end
      it { should be(true) }
    end

    context "when same name project" do
      before do
        user_repo.update subscribed: false
        create :project, user_repo: create(:user_repo, company: user_repo.company), name: user_repo.full_name, company: user_repo.company
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
