class PayloadConsumer

  include Vx::Common::AMQP::Consumer

  exchange 'vx.web.payload'
  queue    'vx.web.payload'
  ack      true

  def perform(message)
    fetcher = BuildFetcher.new(message)
    fetcher.perform

=begin
    project = Project.find_by_token
    payload = ::Github::Payload.new(message)
    project = ::Project.find_by_token message[:token]

    if payload.ignore?
      Rails.logger.info "ignore pull request"
    else
      Build.transaction do
        build = project.create_build_from_github_payload(payload)
        build.delivery_to_fetcher
      end
    end
=end

    ack!
  end

end
