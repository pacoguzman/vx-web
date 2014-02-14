require 'spec_helper'

describe Artifact do
  let(:b)        { create :build }
  let(:artifact) { b.artifacts.build }
  let(:upload)   { File.open Rails.root.join("spec/fixtures/upload_test.tgz") }
  subject { artifact }

  before do
    FileUtils.cp "#{Rails.root}/spec/fixtures/upload.tgz", "#{Rails.root}/spec/fixtures/upload_test.tgz"
  end

  after do
    FileUtils.rm_rf "#{Rails.root}/private/test"
  end

  context "uploaded artifact" do
    before { artifact.update! file: upload, file_name: "main/upload.tgz" }

    it { should be }
    its(:content_type) { should eq 'application/x-gtar' }
    its(:file)         { should be }
    its(:file_name)    { should eq 'main/upload.tgz' }
    its(:file_size)    { should eq 5403 }

    it "file should be exists" do
      expect(File.exists? artifact.file.path).to be
      expect(artifact.file.path).to match(/\/upload_test\.tgz/)
    end
  end
end

# == Schema Information
#
# Table name: artifacts
#
#  id           :integer          not null, primary key
#  build_id     :integer          not null
#  file         :string(255)      not null
#  content_type :string(255)      not null
#  file_size    :string(255)      not null
#  file_name    :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#

