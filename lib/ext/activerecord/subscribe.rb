class ActiveRecord::Base

  def self.pg_subscribe(*channels)
    connection_pool.with_connection do |c|
      conn = c.instance_eval "@connection"
      begin
        channels.each do |ch|
          conn.async_exec "LISTEN #{ch}"
        end
        stop = false
        while !stop
          conn.wait_for_notify(0.5) do |ch, pid, payload|
            yield ch, payload
          end
        end
      ensure
        conn.async_exec 'UNLISTEN *'
      end
    end
  end

  def self.pg_subscribe_channel_name
    table_name
  end

  def pg_subscribe(*channels, &block)
    self.class.pg_subscribe(channels, &block)
  end


end
