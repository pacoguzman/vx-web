class PayloadConsumer

  include Vx::Common::AMQP::Consumer

  exchange 'vx.web.payload'
  queue    'vx.web.payload'
  ack      true

  content_type "application/json"

  model Hash

  def perform(message)
    fetcher = BuildFetcher.new(message)
    fetcher.perform

    ack!
  end

end
