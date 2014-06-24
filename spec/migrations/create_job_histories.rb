require 'spec_helper'

migration_file_name = Dir[Rails.root.join('db/migrate/*_create_job_histories.rb')].first
require migration_file_name

describe CreateJobHistories do
  describe '#up' do
    it 'generates job_histories from existing jobs' do
      migration = CreateJobHistories.new
      migration.down
      now = Time.current
      company = create(:company)
      project = create(:project, company: company)
      build = create(:build, project: project, number: 2)
      job = create(:job, build: build, status: 2, started_at: now - 20.seconds, finished_at: now - 10.seconds, number: 3)

      migration.up
      expect(JobHistory.count).to eq(1)

      job_history = JobHistory.last
      expect(job_history.company_id).to   eq(company.id)
      expect(job_history.build_number).to eq(build.number)
      expect(job_history.job_number).to   eq(job.number)
      expect(job_history.created_at).to   eq(job.finished_at)
    end
  end
end
