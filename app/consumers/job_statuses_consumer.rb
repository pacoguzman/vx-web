class JobStatusesConsumer

  include Evrone::Common::AMQP::Consumer

  exchange 'ci.jobs.status'
  queue    'ci.web.jobs.status'
  ack      true

  model    Evrone::CI::Message::BuildStatus

  def perform(message)
    Rails.logger.tagged("JOB #{message.build_id}.#{message.job_id}") do
      JobUpdater.new(message).perform
    end
    ack!
  end

end
