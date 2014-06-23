require 'spec_helper'

describe CompanyUsage do
  describe '#calculate' do
    it 'returns current company_usage' do
      company = create(:company)
      project = create(:project, company: company)

      today_build = create(:build, project: project, number: 3)
      create(:job, build: today_build, status: "failed", started_at: 20.minutes.ago, finished_at: 10.minutes.ago - 20.seconds)

      yesterday_build = create(:build, project: project, number: 2)
      create(:job, build: yesterday_build, status: "passed", started_at: 1.day.ago.beginning_of_day + 1.hour, finished_at: 1.day.ago.beginning_of_day + 2.hour)

      month_build = create(:build, project: project, number: 1)
      create(:job, build: month_build, status: "passed", started_at: 20.days.ago, finished_at: 20.days.ago + 4.hours)

      company_usage = CompanyUsage.new(company)
      expected_result = {
        today:        { job_count: 1, minutes: 10, amount: 0.10 },
        yesterday:    { job_count: 1, minutes: 60, amount: 0.60 },
        last_7_days:  { job_count: 2, minutes: 70, amount: 0.70 },
        last_30_days: { job_count: 3, minutes: 310, amount: 3.10 }
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
        last_30_days: { job_count: 0, minutes: 0, amount: 0 }
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
        last_30_days: { job_count: 0, minutes: 0, amount: 0.0 }
      }.to_json

      expect(company_usage.to_json).to eq(expected_result)
    end
  end
end
