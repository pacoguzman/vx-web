class JobLogsConsumer

  include Evrone::Common::AMQP::Consumer

  exchange 'ci.jobs.log'
  queue    'ci.web.jobs.log'
  ack      true

  model Evrone::CI::Message::JobLog

  def perform(message)
    Rails.logger.tagged("job_log #{message.build_id}.#{message.job_id}") do
      JobLogsUpdater.new(message).perform
    end
    ack!
  end

end
