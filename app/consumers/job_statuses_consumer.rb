class JobStatusesConsumer

  include Evrone::Common::AMQP::Consumer

  exchange 'ci.jobs.status'
  queue    'ci.web.jobs.status'
  ack      true

  def perform(payload)
    msg = Evrone::CI::Message::JobStatus.parse payload
    Rails.logger.tagged("JOB #{msg.build_id}.#{msg.job_id}") do
      JobUpdater.new(msg).perform
    end
    ack!
  end

end
