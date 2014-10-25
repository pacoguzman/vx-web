require 'spec_helper'

describe User do
  let(:user) { User.new }
  subject { user }

  context "sync_repos" do
    let(:user_repo)     { create :user_repo, external_id: external_repo.id }
    let(:company)       { user_repo.company }
    let(:external_repo) { Vx::ServiceConnector::Model.test_repo }
    let(:identity)      { user_repo.identity }
    let(:user)          { identity.user }

    subject { user.sync_repos(company) }

    it "should create missing user_repos" do
      mock_repos
      user_repo.destroy
      expect {
        subject
      }.to change(identity.user_repos, :count).by(1)
    end

    it "should remove unupdated user_repos" do
      other_company = create :company, id: uuid_for(1), name: "Other Company"
      other_user_repo = create :user_repo, company: other_company, identity: identity, external_id: -1

      mock_repos
      user_repo.update! external_id: -1

      expect(subject).to be
      expect{user_repo.reload}.to raise_error(ActiveRecord::RecordNotFound)
      expect(other_user_repo.reload).to be
    end

    it "should remove if identity return empty array" do
      other_company = create :company, id: uuid_for(1), name: "Other Company"
      other_user_repo = create :user_repo, company: other_company, identity: identity, external_id: -1

      mock_repos []
      user_repo

      expect(subject).to be
      expect{user_repo.reload}.to raise_error(ActiveRecord::RecordNotFound)
      expect(other_user_repo.reload).to be
    end

    it "should keep repos with projects" do
      mock_repos
      user_repo.update! external_id: -1
      create(:project, user_repo: user_repo, company: user_repo.company)

      expect(subject).to be
      expect(user_repo.reload).to be
    end

    it "should update existing user_repos" do
      mock_repos
      user_repo.update! description: "..."
      expect(subject).to be
      expect(user_repo.reload.description).to eq 'description'
    end

    it "should successfuly remove full_name duplicate" do
      mock_repos
      user_repo.update! external_id: -1, full_name: external_repo.full_name
      expect { subject }.to_not change(user.user_repos, :count)
    end

    def mock_repos(list = nil)
      list ||=  [external_repo]

      any_instance_of(Vx::ServiceConnector::Github) do |g|
        mock(g).repos { list }
      end
    end
  end

  context "update_with_company" do
    let(:company) { create :company }
    let(:user)    { create :user }
    it "should update user and its role in company" do
      expect(user).to_not be_admin(company)
      expect(user.update_with_company(company, role: 'admin', name: "NewName")).to be
      expect(user).to be_admin(company)
      expect(user.name).to eq 'NewName'
    end
  end

  context "default_company" do
    let(:user) { create :user }

    let(:c1)  { create :company, name: "c1", id: uuid_for(1) }
    let(:c2)  { create :company, name: "c2", id: uuid_for(2) }
    let!(:uc1) { create :user_company, user: user, company: c1, default: 0 }
    let!(:uc2) { create :user_company, user: user, company: c2, default: 1 }

    it "should return first default company" do
      expect(user.default_company).to eq c2
    end
  end

  context "add_to_company" do
    let(:user) { create :user }
    let(:c1)   { create :company, id: uuid_for(1), name: "c1" }
    let(:c2)   { create :company, id: uuid_for(2), name: "c2" }

    it "should create user_company and set is default" do
      expect(user.add_to_company c1).to be
      expect(user.default_company true).to eq c1

      expect(user.add_to_company c2).to be
      expect(user.default_company true).to eq c2

      expect(user.add_to_company c2).to be
      expect(user.default_company true).to eq c2
    end

    it "should create with developer role by default" do
      expect(user.add_to_company c1).to be
      expect(user).to_not be_admin(c1)
    end

    it "should create with admin role" do
      expect(user.add_to_company c1, role: :admin).to be
      expect(user).to be_admin(c1)
    end

    it 'does not create another user_company if association already exists' do
      user.add_to_company(c1, role: :admin)
      user.add_to_company(c1, role: :admin)

      expect(user.companies).to eq([c1])
    end

    it 'can overrides role' do
      user.add_to_company(c1, role: :admin)
      user.add_to_company(c1, role: :developer)

      expect(user.role(c1)).to eq('admin')

      user.add_to_company(c1, role: :developer, override: true)
      expect(user.role(c1)).to eq('developer')
    end
  end

  describe '#delete_from_company' do
    it 'deletes user from company' do
      company = create(:company)
      user = create(:user)
      user.add_to_company(company)

      user.delete_from_company(company)

      expect(user.companies).to be_blank
    end

    it 'deletes user_repos' do
      company = create(:company)
      user_repo = create(:user_repo, company: company)
      user = user_repo.user
      user.add_to_company(company)

      user.delete_from_company(company)

      expect(user.user_repos).to be_blank
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  email       :string(255)      not null
#  name        :string(255)      not null
#  created_at  :datetime
#  updated_at  :datetime
#  back_office :boolean          default(FALSE)
#  id          :uuid             not null, primary key
#
