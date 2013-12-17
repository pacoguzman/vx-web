module Rails
  extend self

  def shutdown
    Rails.logger.warn '---> Shutdown application'
    @shutdown = true
  end

  def shutdown?
    !!@shutdown
  end
end

#trap("INT") { Thread.new { Rails.shutdown }.join }
trap("TERM") { Thread.new { Rails.shutdown } }
