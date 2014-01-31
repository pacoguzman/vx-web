module Vx
  module Instrumentation
    class ExceptionHandler < Subscriber

      event(/exception/)

      def process
        ex = payload.delete(:exception)
        puts "GOT: #{ex.inspect}"
        if ex
          self.payload = {
            exception: [ex.class.to_s, ex.message.to_s],
            backtrace: ex.backtrace.map(&:to_s).join("\n")
          }
        end
        puts "GOT2: #{self.payload.inspect}"
      end

    end
  end
end
