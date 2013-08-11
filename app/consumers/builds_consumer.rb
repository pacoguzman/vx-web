class BuildsConsumer

  include Evrone::Common::AMQP::Consumer

  exchange 'ci.builds'

end
