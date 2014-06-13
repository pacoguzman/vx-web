require 'spec_helper'

describe JobUpdater, "(regular jobs)" do

  include JobUpdaterIntegrationHelper

  let(:updater) { described_class.new }

  it "when all jobs successfuly completed" do
    build = create :build, status: 0
    job1  = create :job, build: build, number: 1, status: 0
    job2  = create :job, build: build, number: 2, status: 0

    perform(job1, status: 2, tm: 1)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1,  status_name: :started, started_at: 1)
    expect_task(job2,  status_name: :initialized)

    perform(job1, status: 3, tm: 2)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1,  status_name: :passed, started_at: 1, finished_at: 2)
    expect_task(job2,  status_name: :initialized)

    perform(job2, status: 2, tm: 3)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1,  status_name: :passed, started_at: 1, finished_at: 2)
    expect_task(job2,  status_name: :started, started_at: 3)

    perform(job2, status: 3, tm: 4)

    expect_task(build, status_name: :passed, started_at: 1, finished_at: 4)
    expect_task(job1,  status_name: :passed, started_at: 1, finished_at: 2)
    expect_task(job2,  status_name: :passed, started_at: 3, finished_at: 4)
  end

  it "when any of jobs failed" do
    build = create :build, status: 0
    job1  = create :job, build: build, number: 1, status: 0
    job2  = create :job, build: build, number: 2, status: 0

    perform(job1, status: 2, tm: 1)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1,  status_name: :started, started_at: 1)
    expect_task(job2,  status_name: :initialized)

    perform(job1, status: 4, tm: 2)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1,  status_name: :failed, started_at: 1, finished_at: 2)
    expect_task(job2,  status_name: :initialized)

    perform(job2, status: 2, tm: 3)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1,  status_name: :failed, started_at: 1, finished_at: 2)
    expect_task(job2,  status_name: :started, started_at: 3)

    perform(job2, status: 3, tm: 4)

    expect_task(build, status_name: :failed, started_at: 1, finished_at: 4)
    expect_task(job1,  status_name: :failed, started_at: 1, finished_at: 2)
    expect_task(job2,  status_name: :passed, started_at: 3, finished_at: 4)
  end

  it "when any of jobs errored" do
    build = create :build, status: 0
    job1  = create :job, build: build, number: 1, status: 0
    job2  = create :job, build: build, number: 2, status: 0

    perform(job1, status: 2, tm: 1)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1,  status_name: :started, started_at: 1)
    expect_task(job2,  status_name: :initialized)

    perform(job1, status: 5, tm: 2)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1,  status_name: :errored, started_at: 1, finished_at: 2)
    expect_task(job2,  status_name: :initialized)

    perform(job2, status: 2, tm: 3)

    expect_task(build, status_name: :started, started_at: 1)
    expect_task(job1,  status_name: :errored, started_at: 1, finished_at: 2)
    expect_task(job2,  status_name: :started, started_at: 3)

    perform(job2, status: 3, tm: 4)

    expect_task(build, status_name: :errored, started_at: 1, finished_at: 4)
    expect_task(job1,  status_name: :errored, started_at: 1, finished_at: 2)
    expect_task(job2,  status_name: :passed, started_at: 3, finished_at: 4)
  end

end
