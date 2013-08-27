class JobLogsConsumer

  include Evrone::Common::AMQP::Consumer

  exchange 'ci.jobs.log'
  queue    'ci.web.jobs.log'
  ack      true

  model Evrone::CI::Message::BuildStatus

  def perform(message)
    Rails.logger.tagged("JOB LOG #{message.build_id}.#{message.job_id}") do
      JobLogsUpdater.new(message).perform
    end
    ack!
  end

end
