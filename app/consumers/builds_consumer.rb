class BuildsConsumer

  include Vx::Common::AMQP::Consumer

  exchange 'vx.builds'

end
