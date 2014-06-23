class CompanyUsage
  attr_reader :company

  def initialize(company)
    @company = company
  end

  def to_json
    calculate.to_json
  end

  def calculate
    {
      today:        calculate_for_period(from: Time.current.beginning_of_day,   to: Time.current),
      yesterday:    calculate_for_period(from: 1.day.ago.beginning_of_day,      to: 1.day.ago.end_of_day),
      last_7_days:  calculate_for_period(from: 7.days.ago.beginning_of_day,     to: Time.current),
      this_month:   calculate_for_period(from: Time.current.beginning_of_month, to: Time.current)
    }
  end

  private

    def calculate_for_period(options)
      query = %{
        SELECT
          COUNT(*) AS job_count,
          CEIL(SUM(EXTRACT(EPOCH FROM AGE(jobs.finished_at, jobs.started_at))) / 60.0) AS minutes
        FROM jobs
        INNER JOIN builds ON builds.id = jobs.build_id
        INNER JOIN projects ON projects.id = builds.project_id
        WHERE
          projects.company_id = ? AND
          jobs.started_at IS NOT NULL AND jobs.finished_at IS NOT NULL AND
          jobs.finished_at > ? AND jobs.finished_at < ?
      }.compact

      query  = Job.send(:sanitize_sql_array, [query, company.id, options[:from], options[:to]])

      result = Job.connection.select_one(query)
      result = result.map { |key, value| { key.to_sym => value.to_i } }.reduce(:merge)
      amount = result[:minutes] # TODO use hourly rate here
      result[:amount] = amount.to_f / 100.0
      result
    end
end
