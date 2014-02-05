class JobLogsConsumer

  include Vx::Consumer

  exchange 'vx.jobs.log'
  queue    'vx.web.jobs.log'
  ack

  model Vx::Message::JobLog

  def perform(message)
    JobLogsUpdater.new(message).perform
    ack
  end

end
