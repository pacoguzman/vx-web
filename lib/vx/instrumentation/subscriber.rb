require 'logger'
require 'active_support/notifications'

module Vx
  module Instrumentation
    Subscriber = Struct.new(:name, :payload, :tags) do

      def process ; end

      class << self

        def install
          ev = event || /.*/
          $stdout.puts " --> add instrumentation #{self.to_s} to #{ev.inspect}"
          ActiveSupport::Notifications.subscribe(ev) do |name, started, finished, uid, payload|
            if name[0] != '!'
              tags = name.split(".")
              inst = new(name, payload, tags).tap(&:process)
              delivery(inst.name, inst.payload, inst.tags.uniq, started, finished)
            end
          end
        end

        def error!(event, ex, env)

          tags = event.split(".")
          tags << "exception"
          tags.uniq!

          payload = {
            "@event"      => event,
            "@process_id" => Process.pid,
            "@thread_id"  => Thread.current.object_id,
            "@timestamp"  => Time.now,
            "@tags"       => tags,
            "@fields"     => env,
            exception: ex.class.to_s,
            message:   ex.message.to_s,
            backtrace: ex.backtrace.map(&:to_s).join("\n"),
          }
          puts "GOT: #{payload.inspect}"
          Vx::Instrumentation::Logger.logger.log(
            ::Logger::ERROR, payload
          )
        end

        def delivery(name, payload, tags, started, finished)
          tm = started.strftime('%Y-%m-%dT%H:%M:%S.%N%z')
          Vx::Instrumentation::Logger.logger.log(
            ::Logger::INFO,
            "@event"      => name,
            "@process_id" => Process.pid,
            "@thread_id"  => Thread.current.object_id,
            "@timestamp"  => tm,
            "@duration"   => (finished - started).to_f,
            "@fields"     => payload,
            "@tags"       => tags
          )
        end

        def event(name = nil)
          @event = name if  name
          @event
        end

      end

    end
  end
end
