require 'json'
require 'logger'

module Vx

  module Common

    class Logger

      def initialize(device)
        @device = device
      end

      def method_missing(sym, *args, &block)
        if @device.respond_to?(sym)
          @device.send(sym, *args, &block)
        else
          super
        end
      end

      def with(new_keys)
        old_keys = Thread.current["vx_logger_keys"]
        begin
          Thread.current["vx_logger_keys"] = (old_keys || {}).merge(new_keys)
          yield if block_given?
        ensure
          Thread.current["vx_logger_keys"] = old_keys
        end
      end

      def respond_to?(sym)
        @device.respond_to?(sym)
      end

      class << self
        attr_accessor :logger

        def setup(target)
          puts "=== SETUP: #{target}"
          log = ::Logger.new(target)
          log.formatter = Formatter
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
          formatted.to_json + "\n"
        end

      end

    end

  end
end
