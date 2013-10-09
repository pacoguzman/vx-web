class JobStatusConsumer

  include Evrone::Common::AMQP::Consumer

  exchange 'ci.jobs.status'
  queue    'ci.web.jobs.status'
  ack      true

  model    Evrone::CI::Message::JobStatus

  def perform(message)
    Rails.logger.tagged("job #{message.build_id}.#{message.job_id}") do
      JobUpdater.new(message).perform
    end
    ack!
  end

end
