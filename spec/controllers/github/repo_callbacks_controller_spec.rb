require 'spec_helper'

describe Github::RepoCallbacksController do

  subject { response }

  describe "GET /create" do
    let(:token)   { 'token'     }
    let(:project) { Project.new }
    let(:payload) { 'payload' }
    let(:build)   { 'build' }
    before do
      mock(Project).find_by_token(token) { project }
      mock(Github::Payload).new(hash_including(token: token)) { payload }
      mock(project).create_build_from_github_payload(payload) { build }
      mock(build).publish(:created)
      mock(build).publish_perform_build_message

      get :create, token: token
    end

    it { should be_success }

  end

end
