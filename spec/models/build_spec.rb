require 'spec_helper'

describe Build do
  let(:build)   { Build.new       }
  let(:project) { create :project }
  subject       { build           }

  context "before creation" do
    subject { ->{ build.save! } }
    before { build.project = project }

    context "assign number" do

      it "should be 1 when no other builds" do
        expect(subject).to change(build, :number).to(1)
      end

      it "should increment when any other builds exist" do
        create :build, project: project
        expect(subject).to change(build, :number).to(2)
      end
    end

    context "assign sha" do
      it "by default should be 'HEAD'" do
        expect(subject).to change(build, :sha).to("HEAD")
      end

      it "when exists dont touch sha" do
        build.sha = '1234'
        expect(subject).to_not change(build, :sha)
      end
    end

    context "assign branch" do
      it "by default should be 'master'" do
        expect(subject).to change(build, :branch).to("master")
      end

      it "when exists dont touch branch" do
        build.branch = '1234'
        expect(subject).to_not change(build, :branch)
      end
    end

  end


end

# == Schema Information
#
# Table name: builds
#
#  id              :integer          not null, primary key
#  number          :integer          not null
#  project_id      :integer          not null
#  sha             :string(255)      not null
#  branch          :string(255)      not null
#  pull_request_id :integer
#  author          :string(255)
#  message         :string(255)
#  status          :integer          default(0), not null
#  started_at      :datetime
#  finished_at     :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  author_email    :string(255)
#  jobs_count      :integer          default(0), not null
#  http_url        :string(255)
#

