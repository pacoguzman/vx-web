class JobStatusConsumer

  include Vx::Consumer

  exchange 'vx.jobs.status'
  queue    'vx.web.jobs.status'
  ack

  model    Vx::Lib::Message::JobStatus

  def perform(message)
    JobUpdater.new(message).perform
    ack
  end

end
