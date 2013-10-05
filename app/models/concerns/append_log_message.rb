module AppendLogMessage

  def append_log_message(log_message)
    pa         = self.proxy_association
    fkey       = pa.reflection.foreign_key
    fkey_value = pa.owner.id
    data       = log_message.log

    sql = "INSERT INTO #{self.table_name}"
    sql << " (tm, tm_usec, data, #{fkey})"
    sql << " VALUES(?, 0, ?, ?)"

    sql = pa.reflection.klass.send(:sanitize_sql, [sql, log_message.tm, data, fkey_value])
    connection.execute sql

    self.new tm: log_message.tm, tm_usec: 0, data: data
  end

end
