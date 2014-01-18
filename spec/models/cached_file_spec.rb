require 'spec_helper'
require 'fileutils'

describe CachedFile do
  let(:project) { create :project }
  let(:file)    { project.cached_files.build }
  let(:upload)  { File.open Rails.root.join("spec/fixtures/upload_test.tgz") }
  subject { file }

  before do
    FileUtils.cp "#{Rails.root}/spec/fixtures/upload.tgz", "#{Rails.root}/spec/fixtures/upload_test.tgz"
  end

  after do
    FileUtils.rm_rf "#{Rails.root}/private/test"
  end

  context "uploaded file" do
    before { file.update! file: upload, file_name: "main/upload.tgz" }

    it { should be }
    its(:content_type) { should eq 'application/x-gtar' }
    its(:file)         { should be }
    its(:file_name)    { should eq 'main/upload.tgz' }
    its(:file_size)    { should eq 5403 }

    it "file should be exists" do
      expect(File.exists? file.file.path).to be
      expect(file.file.path).to match(/\/orig\.tgz/)
    end
  end
end
