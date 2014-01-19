require 'spec_helper'

describe Api::CachedFilesController do
  let(:project) { create :project }
  subject { response }

  after do
    FileUtils.rm_rf "#{Rails.root}/private/test"
  end

  context "PUT /upload" do
    before { upload }

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

  context "GET /download" do
    let(:upload)  { File.open Rails.root.join("spec/fixtures/upload_test.tgz") }

    before { download }

    it { should be_success }
    its(:content_type) { should eq 'application/x-gtar' }
    its(:body) { should have(5403).items }

    def download
      FileUtils.cp "#{Rails.root}/spec/fixtures/upload.tgz", "#{Rails.root}/spec/fixtures/upload_test.tgz"
      project.cached_files.create! file: upload, file_name: "main/foo.tgz"
      get :download, { token: project.token, file_name: "main/foo", file_ext: "tgz" }
    end
  end

end
