class JobLogsConsumer

  include Vx::Common::AMQP::Consumer

  exchange 'vx.jobs.log'
  queue    'vx.web.jobs.log'
  ack      true

  model Vx::Message::JobLog

  def perform(message)
    JobLogsUpdater.new(message).perform
    ack!
  end

end
