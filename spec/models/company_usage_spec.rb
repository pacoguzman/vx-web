require 'spec_helper'

describe CompanyUsage do
  describe '#calculate' do
    it 'returns current company_usage' do
      company = create(:company)
      project = create(:project, company: company)

      now = Time.current

      today_build = create(:build, project: project, number: 3)
      today_job = create(:job, build: today_build, status: 2, started_at: now - 20.minutes, finished_at: now - 10.minutes - 20.seconds)
      today_job.pass

      yesterday_build = create(:build, project: project, number: 2)
      yesterday_job = create(:job, build: yesterday_build, status: 2, started_at: (now - 1.day).beginning_of_day + 1.hour, finished_at: (now - 1.day).beginning_of_day + 2.hour)
      yesterday_job.decline

      month_build = create(:build, project: project, number: 1)
      month_job = create(:job, build: month_build, status: 2, started_at: now - 20.days, finished_at: now - 20.days + 4.hours)
      month_job.error

      company_usage = CompanyUsage.new(company)
      expected_result = {
        today:        { job_count: 1, minutes: 10, amount: 0.10 },
        yesterday:    { job_count: 1, minutes: 60, amount: 0.60 },
        last_7_days:  { job_count: 2, minutes: 70, amount: 0.70 },
        this_month:   { job_count: 3, minutes: 310, amount: 3.10 }
      }

      expect(company_usage.calculate).to eq(expected_result)
    end

    it 'returns zeros if no jobs' do
      company = create(:company)
      company_usage = CompanyUsage.new(company)
      expected_result = {
        today:        { job_count: 0, minutes: 0, amount: 0 },
        yesterday:    { job_count: 0, minutes: 0, amount: 0 },
        last_7_days:  { job_count: 0, minutes: 0, amount: 0 },
        this_month:   { job_count: 0, minutes: 0, amount: 0 }
      }

      expect(company_usage.calculate).to eq(expected_result)
    end
  end

  describe '#to_json' do
    it 'calculates and returns data as json' do
      company = create(:company)
      company_usage = CompanyUsage.new(company)
      expected_result = {
        today:        { job_count: 0, minutes: 0, amount: 0.0 },
        yesterday:    { job_count: 0, minutes: 0, amount: 0.0 },
        last_7_days:  { job_count: 0, minutes: 0, amount: 0.0 },
        this_month:   { job_count: 0, minutes: 0, amount: 0.0 }
      }.to_json

      expect(company_usage.to_json).to eq(expected_result)
    end
  end
end
