class JobStatusConsumer

  include Vx::Common::AMQP::Consumer

  exchange 'vx.jobs.status'
  queue    'vx.web.jobs.status'
  ack      true

  model    Vx::Message::JobStatus

  def perform(message)
    Rails.logger.tagged("job #{message.build_id}.#{message.job_id}") do
      JobUpdater.new(message).perform
    end
    ack!
  end

end
