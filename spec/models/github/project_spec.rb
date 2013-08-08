require 'spec_helper'

describe Github::Project do
  let(:project) { Project.new }

  context ".github" do
    subject { Project.github }
    let(:project) { create :project, :github }

    it { should eq [project] }
  end

end
