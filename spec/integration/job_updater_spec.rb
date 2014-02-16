require 'spec_helper'

describe JobUpdater do
  let(:updater) { described_class.new }

  it "when all jobs successfuly completed" do
    build = create :build, status: 0
    job1  = create :job, build: build, number: 1, status: 0
    job2  = create :job, build: build, number: 2, status: 0

    perform(job1, 2, 1)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1, status_name: :started, started_at: 1)
    expect_task(job2, status_name: :initialized)

    perform(job1, 3, 2)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1, status_name: :passed, started_at: 1, finished_at: 2)
    expect_task(job2, status_name: :initialized)

    perform(job2, 2, 3)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1, status_name: :passed, started_at: 1, finished_at: 2)
    expect_task(job2, status_name: :started, started_at: 3)

    perform(job2, 3, 4)

    expect_task(build, status_name: :passed, started_at: 1, finished_at: 4)
    expect_task(job1, status_name: :passed, started_at: 1, finished_at: 2)
    expect_task(job2, status_name: :passed, started_at: 3, finished_at: 4)
  end

  it "when any of jobs failed" do
    build = create :build, status: 0
    job1  = create :job, build: build, number: 1, status: 0
    job2  = create :job, build: build, number: 2, status: 0

    perform(job1, 2, 1)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1, status_name: :started, started_at: 1)
    expect_task(job2, status_name: :initialized)

    perform(job1, 4, 2)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1, status_name: :failed, started_at: 1, finished_at: 2)
    expect_task(job2, status_name: :initialized)

    perform(job2, 2, 3)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1, status_name: :failed, started_at: 1, finished_at: 2)
    expect_task(job2, status_name: :started, started_at: 3)

    perform(job2, 3, 4)

    expect_task(build, status_name: :failed, started_at: 1, finished_at: 4)
    expect_task(job1, status_name: :failed, started_at: 1, finished_at: 2)
    expect_task(job2, status_name: :passed, started_at: 3, finished_at: 4)
  end

  it "when any of jobs errored" do
    build = create :build, status: 0
    job1  = create :job, build: build, number: 1, status: 0
    job2  = create :job, build: build, number: 2, status: 0

    perform(job1, 2, 1)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1, status_name: :started, started_at: 1)
    expect_task(job2, status_name: :initialized)

    perform(job1, 5, 2)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1, status_name: :errored, started_at: 1, finished_at: 2)
    expect_task(job2, status_name: :initialized)

    perform(job2, 2, 3)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1, status_name: :errored, started_at: 1, finished_at: 2)
    expect_task(job2, status_name: :started, started_at: 3)

    perform(job2, 3, 4)

    expect_task(build, status_name: :errored, started_at: 1, finished_at: 4)
    expect_task(job1, status_name: :errored, started_at: 1, finished_at: 2)
    expect_task(job2, status_name: :passed, started_at: 3, finished_at: 4)
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

  def perform(job, status, tm = nil)
    JobUpdater.new(
      message(job, status, tm)
    ).perform
  end

  def message(job, status, tm = nil)
    Vx::Message::JobStatus.test_message(
      project_id: job.build.project_id,
      build_id: job.build_id,
      job_id: job.number,
      status: status,
      tm: Time.at(tm) || Time.now
    )
  end
end
