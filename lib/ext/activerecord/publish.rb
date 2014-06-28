module Vx
  module Web
    module Publish

      def publish(event = nil, options = {})
        event ||= :updated
        channel = options[:channel] || :default

        serializer = options[:serializer]
        serializer ||= begin
          "#{self.class.to_s.underscore}"
        end
        serializer = "#{serializer.camelize}Serializer".constantize

        payload = serializer.new(self).as_json
        event   = "#{self.class.table_name.singularize}:#{event}"

        message = {
          channel: channel,
          event:   'event',
          _event:  event,
          payload: payload
        }

        SockdNotifyConsumer.publish message, type: channel

        true
      end

    end
  end
end


ActiveRecord::Base.send :include, Vx::Web::Publish
