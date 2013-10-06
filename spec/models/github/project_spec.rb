require 'spec_helper'

describe Github::Project do
  let(:project) { Project.new }

  context ".github" do
    subject { Project.github }
    let(:project) { create :project, :github }

    it { should eq [project] }
  end

  context "#create_build_from_github_payload" do
    let(:project)         { create :project }
    let(:pull_request_id) { 1 }
    let(:branch)          { 'branch' }
    let(:branch_label)    { 'branch:label' }
    let(:head)            { 'head' }
    let(:url)             { 'url' }
    let(:payload)         {
      OpenStruct.new pull_request_number: pull_request_id,
                     branch: branch,
                     head: head,
                     url: url,
                     branch_label: branch_label
    }
    subject { project.create_build_from_github_payload payload }

    context "successfuly created build" do
      its(:pull_request_id) { should eq pull_request_id }
      its(:branch)          { should eq branch }
      its(:branch_label)    { should eq branch_label }
      its(:sha)             { should eq head }
      its(:http_url)        { should eq url }
    end

    context "fail" do
      before do
        any_instance_of(Build) do |b|
          mock(b).save { false }
        end
      end

      it "cannot touch any builds" do
        expect{ subject }.to_not change(Build, :count)
      end

      it { should be_false }
    end
  end

end

# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  http_url    :string(255)      not null
#  clone_url   :string(255)      not null
#  description :text
#  provider    :string(255)
#  deploy_key  :text             not null
#  token       :string(255)      not null
#  created_at  :datetime
#  updated_at  :datetime
#

