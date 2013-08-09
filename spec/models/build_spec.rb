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

    context "assign ref" do
      it "by default should be 'HEAD'" do
        expect(subject).to change(build, :ref).to("HEAD")
      end

      it "when exists dont touch ref" do
        build.ref = '1234'
        expect(subject).to_not change(build, :ref)
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
