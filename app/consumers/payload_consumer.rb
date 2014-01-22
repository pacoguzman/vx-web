class PayloadConsumer

  include Vx::Common::AMQP::Consumer

  exchange 'vx.web.payload'
  queue    'vx.web.payload'
  ack      true

  content_type "application/json"

  model Hash

  def perform(payload)
    fetcher = BuildFetcher.new(payload)
    fetcher.perform

    ack!
  end

end
