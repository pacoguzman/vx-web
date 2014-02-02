class JobStatusConsumer

  include Vx::Common::AMQP::Consumer

  exchange 'vx.jobs.status'
  queue    'vx.web.jobs.status'
  ack      true

  model    Vx::Message::JobStatus

  def perform(message)
    JobUpdater.new(message).perform
    ack!
  end

end
