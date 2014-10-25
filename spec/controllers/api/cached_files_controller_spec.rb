require 'spec_helper'

describe Api::CachedFilesController do
  let(:project) { create :project }
  subject { response }

  after do
    FileUtils.rm_rf "#{Rails.root}/private/test"
  end

  context "POST /mass_destroy" do
    let(:content)  { File.open Rails.root.join("spec/fixtures/upload_test.tgz") }

    it "should destroy files" do
      FileUtils.cp "#{Rails.root}/spec/fixtures/upload.tgz", "#{Rails.root}/spec/fixtures/upload_test.tgz"
      file = project.cached_files.create! file: content, file_name: "main/foo.tgz"

      sign_in create(:user), project.company
      post :mass_destroy, project_id: project.id, ids: file.id

      should be_success
      expect{ file.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
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

    it "has a body of the correct size" do
      subject.body.size.should eq 5403
    end

    def download
      FileUtils.cp "#{Rails.root}/spec/fixtures/upload.tgz", "#{Rails.root}/spec/fixtures/upload_test.tgz"
      project.cached_files.create! file: upload, file_name: "main/foo.tgz"
      get :download, { token: project.token, file_name: "main/foo", file_ext: "tgz" }
    end
  end

end
