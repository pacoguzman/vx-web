class JobLogsConsumer

  include Evrone::Common::AMQP::Consumer

  exchange 'ci.jobs.log'
  queue    'ci.web.jobs.log'
  ack      true

  def perform(payload)
    msg = Evrone::CI::Message::JobLog.parse payload
    puts msg.inspect
    Rails.logger.tagged("JOB LOG #{msg.build_id}.#{msg.job_id}") do
      JobLogsUpdater.new(msg).perform
    end
    ack!
  end

end
