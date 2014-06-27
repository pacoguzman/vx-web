require 'spec_helper'

describe UserReposSerializer do
  it "should work with same_name_projects" do
    repo = create(:user_repo, full_name: "repo")
    create(:project, name: "repo", company: repo.company)

    dont_allow(repo).same_name_projects?

    s = described_class.new([repo], scope: OpenStruct.new(default_company: repo.company))
    expect(s.same_name_projects).to eq ['repo']
    expect(s.to_json).to be
  end

  it "should work with empty same_name_projects" do
    repo = create(:user_repo, full_name: "repo")

    dont_allow(repo).same_name_projects?

    s = described_class.new([repo], scope: OpenStruct.new(default_company: repo.company))
    expect(s.same_name_projects).to eq []
    expect(s.to_json).to be
  end
end
