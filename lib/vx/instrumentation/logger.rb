require 'json'
require 'logger'

module Vx

  module Instrumentation

    class Logger

      def initialize(device)
        @device = device
      end

      def method_missing(sym, *args, &block)
        if @device.respond_to?(sym)
          begin
            @device.send(sym, *args, &block)
          rescue Exception => e
            $stderr.puts "#{e.class.to_s} in #{e.message.inspect} [#{sym.inspect} #{args.inspect}]"
            $stderr.puts e.backtrace.map{|b| "    #{b}" }.join("\n")
          end
        else
          super
        end
      end

      def respond_to?(sym)
        @device.respond_to?(sym)
      end

      class << self
        attr_accessor :logger

        def setup(target)
          log = ::Logger.new(target)
          log.formatter = Formatter
          $stdout.puts " --> #{self.to_s} to #{target}"
          @logger = new(log)
        end
      end

      class Formatter

        def self.call(severity, tm, _, msg)
          formatted =
            case
            when msg.is_a?(Hash)
              msg
            when msg.respond_to?(:to_h)
              msg.to_h
            else
              { message: msg }
            end
          formatted.merge!(severity: severity.to_s.downcase, tm: tm.to_f)

          flat = formatted.inject({}) do |a, val|
            k,v = val
            if k == '@fields'
              fields = {}
              v.each do |f_k, f_v|
                fields[f_k] =
                  case f_v
                  when String, Symbol, Fixnum, Float
                    f_v
                  else
                    f_v.to_s
                  end
                  f_v.is_a?(String) ? f_v : f_v.inspect
              end
              v = fields
            end
            a[k] = v
            a
          end
          ::JSON.dump(flat) + "\n"
        end

      end

    end

  end
end
