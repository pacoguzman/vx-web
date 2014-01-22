require 'spec_helper'

describe Github::Project do
  let(:project) { Project.new }

  context ".github" do
    subject { Project.github }
    let(:project) { create :project, :github }

    it { should eq [project] }
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
#  identity_id :integer
#

