class ActiveRecord::Base

  class << self
    def pg_notify(channel = nil, payload = nil)
      connection_pool.with_connection do |c|
        channel ||= table_name
        s = "NOTIFY #{channel}"
        s << ", #{c.quote payload}" if payload
        c.execute s
      end
    end
  end

  def pg_notify(channel = nil, payload = nil)
    channel ||= "#{self.class.table_name}_#{id}" unless new_record?
    self.class.pg_notify channel, payload
  end

end
