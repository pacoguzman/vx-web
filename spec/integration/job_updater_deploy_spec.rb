require 'spec_helper'

describe JobUpdater, "(deploy jobs)", type: "model" do

  include JobUpdaterIntegrationHelper

  let(:updater) { described_class.new }

  context "only deploy tasks" do
    it "when all jobs successfuly completed" do
      build = create :build, status: "initialized"
      job1  = create :job, build: build, number: 1, status: "initialized", kind: 'deploy'
      job2  = create :job, build: build, number: 2, status: "initialized", kind: 'deploy'

      perform(job1, status: 2, tm: 1)

      expect_task(build, status_name: :deploying, started_at: 1)
      expect_task(job1,  status_name: :started, started_at: 1)
      expect_task(job2,  status_name: :initialized)

      perform(job1, status: 3, tm: 2)

      expect_task(build, status_name: :deploying, started_at: 1)
      expect_task(job1,  status_name: :passed, started_at: 1, finished_at: 2)
      expect_task(job2,  status_name: :initialized)
      expect_last_perform_message(job2)

      perform(job2, status: 2, tm: 3)

      expect_task(build, status_name: :deploying, started_at: 1)
      expect_task(job1,  status_name: :passed, started_at: 1, finished_at: 2)
      expect_task(job2,  status_name: :started, started_at: 3)
      expect_last_perform_message(nil)

      perform(job2, status: 3, tm: 4)

      expect_task(build, status_name: :passed, started_at: 1, finished_at: 4)
      expect_task(job1,  status_name: :passed, started_at: 1, finished_at: 2)
      expect_task(job2,  status_name: :passed, started_at: 3, finished_at: 4)
      expect_last_perform_message(nil)
    end
  end

  context "regular and deploy tasks" do

    it "when all jobs successfuly completed" do
      build = create :build, status: "initialized"
      job1  = create :job, build: build, number: 1, status: "initialized", kind: 'regular'
      job2  = create :job, build: build, number: 2, status: "initialized", kind: 'deploy'

      perform(job1, status: 2, tm: 1)

      expect_task(build, status_name: :started, started_at: 1)
      expect_task(job1,  status_name: :started, started_at: 1)
      expect_task(job2,  status_name: :initialized)

      perform(job1, status: 3, tm: 2)

      expect_task(build, status_name: :deploying, started_at: 1)
      expect_task(job1,  status_name: :passed, started_at: 1, finished_at: 2)
      expect_task(job2,  status_name: :initialized)
      expect_last_perform_message(job2)

      perform(job2, status: 2, tm: 3)

      expect_task(build, status_name: :deploying, started_at: 1)
      expect_task(job1,  status_name: :passed, started_at: 1, finished_at: 2)
      expect_task(job2,  status_name: :started, started_at: 3)
      expect_last_perform_message(nil)

      perform(job2, status: 3, tm: 4)

      expect_task(build, status_name: :passed, started_at: 1, finished_at: 4)
      expect_task(job1,  status_name: :passed, started_at: 1, finished_at: 2)
      expect_task(job2,  status_name: :passed, started_at: 3, finished_at: 4)
      expect_last_perform_message(nil)
    end

    it "when regular job failed" do
      build = create :build, status: "initialized"
      job1  = create :job, build: build, number: 1, status: "initialized", kind: 'regular'
      job2  = create :job, build: build, number: 2, status: "initialized", kind: 'deploy'

      perform(job1, status: 2, tm: 1)

      expect_task(build, status_name: :started, started_at: 1)
      expect_task(job1,  status_name: :started, started_at: 1)
      expect_task(job2,  status_name: :initialized)

      perform(job1, status: 4, tm: 2)

      expect_task(build, status_name: :failed, started_at: 1, finished_at: 2)
      expect_task(job1,  status_name: :failed, started_at: 1, finished_at: 2)
      expect_task(job2,  status_name: :cancelled)
      expect_last_perform_message(nil)
    end

    it "when regular job errored" do
      build = create :build, status: "initialized"
      job1  = create :job, build: build, number: 1, status: "initialized", kind: 'regular'
      job2  = create :job, build: build, number: 2, status: "initialized", kind: 'deploy'

      perform(job1, status: 2, tm: 1)

      expect_task(build, status_name: :started, started_at: 1)
      expect_task(job1,  status_name: :started, started_at: 1)
      expect_task(job2,  status_name: :initialized)

      perform(job1, status: 5, tm: 2)

      expect_task(build, status_name: :errored, started_at: 1, finished_at: 2)
      expect_task(job1,  status_name: :errored, started_at: 1, finished_at: 2)
      expect_task(job2,  status_name: :cancelled)
      expect_last_perform_message(nil)
    end

    it "when deploy job failed" do
      build = create :build, status: "initialized"
      job1  = create :job, build: build, number: 1, status: "initialized", kind: 'regular'
      job2  = create :job, build: build, number: 2, status: "initialized", kind: 'deploy'

      perform(job1, status: 2, tm: 1)

      expect_task(build, status_name: :started, started_at: 1)
      expect_task(job1,  status_name: :started, started_at: 1)
      expect_task(job2,  status_name: :initialized)

      perform(job1, status: 3, tm: 2)

      expect_task(build, status_name: :deploying, started_at: 1)
      expect_task(job1,  status_name: :passed, started_at: 1, finished_at: 2)
      expect_task(job2,  status_name: :initialized)
      expect_last_perform_message(job2)

      perform(job2, status: 2, tm: 3)

      expect_task(build, status_name: :deploying, started_at: 1)
      expect_task(job1,  status_name: :passed, started_at: 1, finished_at: 2)
      expect_task(job2,  status_name: :started, started_at: 3)
      expect_last_perform_message(nil)

      perform(job2, status: 4, tm: 4)

      expect_task(build, status_name: :failed, started_at: 1, finished_at: 4)
      expect_task(job1,  status_name: :passed, started_at: 1, finished_at: 2)
      expect_task(job2,  status_name: :failed, started_at: 3, finished_at: 4)
      expect_last_perform_message(nil)
    end

  end

end
