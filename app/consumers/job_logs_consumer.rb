class JobLogsConsumer

  include Vx::Common::AMQP::Consumer

  exchange 'vx.jobs.log'
  queue    'vx.web.jobs.log'
  ack      true

  model Vx::Message::JobLog

  def perform(message)
    Rails.logger.silence(:stdout) do
      Rails.logger.tagged("job_log #{message.build_id}.#{message.job_id}") do
        JobLogsUpdater.new(message).perform
      end
    end
    ack!
  end

end
