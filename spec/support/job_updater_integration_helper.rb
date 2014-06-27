module JobUpdaterIntegrationHelper
  def expect_last_perform_message(job, options = {})
    m = JobsConsumer.messages.last

    if job == nil
      expect(m).to be_nil
    else
      expect(m.job_id).to       eq job.id.to_s
      expect(m.job_number).to   eq job.number
      expect(m.build_id).to     eq job.build.id.to_s
      expect(m.build_number).to eq job.build.number
    end

    JobsConsumer.messages.clear
  end

  def expect_task(task, options = {})
    task.reload
    if s = options[:status_name]
      expect(task.status_name).to eq s
    end
    if t = options[:started_at]
      expect(task.started_at.to_i).to eq t
    else
      expect(task.started_at).to be_nil
    end
    if t = options[:finished_at]
      expect(task.finished_at.to_i).to eq t
    else
      expect(task.finished_at).to be_nil
    end
  end

  def perform(job, options = {})
    JobUpdater.new(
      message(job, options[:status], options[:tm])
    ).perform
  end

  def message(job, status, tm = nil)
    Vx::Message::JobStatus.test_message(
      company_id:   job.company.id,
      project_id:   job.project.id,
      build_id:     job.build_id,
      job_id:       job.id,
      status:       status,
      tm:           Time.at(tm) || Time.now
    )
  end
end
