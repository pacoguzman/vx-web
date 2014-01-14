class JobsConsumer

  include Vx::Common::AMQP::Consumer

  exchange 'vx.jobs'

end
