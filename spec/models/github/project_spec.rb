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
    let(:pull_request_id) { 1               }
    let(:branch)          { 'branch'        }
    let(:head)            { 'head'          }
    let(:payload)         {
      OpenStruct.new pull_request_number: pull_request_id,
                     branch: branch,
                     head: head
    }
    subject { project.create_build_from_github_payload payload }

    context "successfuly created build" do
      its(:pull_request_id) { should eq pull_request_id }
      its(:branch)          { should eq branch          }
      its(:sha)             { should eq head            }
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
