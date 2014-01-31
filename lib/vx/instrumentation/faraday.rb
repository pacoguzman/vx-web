module Vx
  module Instrumentation
    class Faraday < Subscriber

      event 'request.faraday'

      def process
        self.name    = 'request.http'
        self.payload = {
          method:           payload[:method],
          url:              payload[:url].to_s,
          status:           payload[:status],
          response_headers: render_http_header(payload[:response_headers]),
          request_headers:  render_http_header(payload[:request_headers])
        }
      end

      private

        def render_http_header(headers)
          headers.map do |key,value|
            if %{ PRIVATE-TOKEN Authorization }.include?(key)
              value = value.gsub(/./, "*")
            end
            "#{key}: #{value}"
          end.join("\n")
        end

    end
  end
end
