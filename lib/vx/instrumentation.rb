require 'thread'

require File.expand_path("../instrumentation/logger",            __FILE__)
require File.expand_path("../instrumentation/subscriber",        __FILE__)

require File.expand_path("../instrumentation/faraday",           __FILE__)
require File.expand_path("../instrumentation/active_record",     __FILE__)
require File.expand_path("../instrumentation/action_dispatch",   __FILE__)
require File.expand_path("../instrumentation/rails",             __FILE__)
require File.expand_path("../instrumentation/amqp_consumer",     __FILE__)

module Vx
  module Instrumentation

    extend self

    def install(target)
      Instrumentation::Logger.setup target
      Instrumentation::Logger.logger.level = 0
      Instrumentation::Subscriber.subclasses.map(&:install)
    end

    def with(new_keys)
      old_keys = Thread.current["vx_instrumentation_keys"]
      begin
        Thread.current["vx_instrumentation_keys"] = (old_keys || {}).merge(new_keys)
        yield if block_given?
      ensure
        Thread.current["vx_instrumentation_keys"] = old_keys
      end
    end

  end

end
