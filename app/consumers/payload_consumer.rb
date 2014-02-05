class PayloadConsumer

  include Vx::Consumer

  exchange 'vx.web.payload'
  queue    'vx.web.payload'
  ack

  content_type "application/json"

  model Hash

  def perform(payload)
    fetcher = BuildFetcher.new(payload)
    fetcher.perform

    ack
  end

end
