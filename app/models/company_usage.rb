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
      today:      calculate_for_period(from: Time.current.beginning_of_day,   to: Time.current),
      yesterday:  calculate_for_period(from: 1.day.ago.beginning_of_day,      to: 1.day.ago.end_of_day),
      this_week:  calculate_for_period(from: Time.current.beginning_of_week,  to: Time.current),
      this_month: calculate_for_period(from: Time.current.beginning_of_month, to: Time.current)
    }
  end

  def calculate_for_period(options)
    query = %{
      SELECT
        COUNT(job_histories.job_number) AS job_count,
        SUM(CEIL(job_histories.duration / 60.0)) AS minutes
      FROM job_histories
      WHERE job_histories.company_id = ? AND job_histories.created_at > ? AND job_histories.created_at < ?
    }.squish

    query  = JobHistory.send(:sanitize_sql_array, [query, company.id, options[:from], options[:to]])

    result = JobHistory.connection.select_one(query)
    result = result.map { |key, value| { key.to_sym => value.to_i } }.reduce(:merge)
    result[:amount] = result[:minutes].to_f / 100.0
    result
  end
end
