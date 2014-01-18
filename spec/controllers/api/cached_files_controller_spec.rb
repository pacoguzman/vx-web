require 'spec_helper'

describe Api::CachedFilesController do
  subject { response }

  context "PUT /upload" do
    let(:project) { create :project }

    before do
      upload
    end

    after do
      FileUtils.rm_rf "#{Rails.root}/private/test"
    end

    it { should be_success }

    it "should upload and create cached file" do
      file = project.cached_files.first
      expect(file).to be
      expect(file.file_name).to eq 'main/foo.tgz'
      expect(File.exists? file.file.path).to be
    end

    def upload
      io = File.read("#{Rails.root}/spec/fixtures/upload.tgz")
      @request.env["RAW_POST_DATA"] = io
      put :upload, { token: project.token, file_name: "main/foo", file_ext: "tgz" }, 'CONTENT_TYPE' => 'application/octet-stream'
    end
  end

end
