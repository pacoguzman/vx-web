module AppendLogMessage

  def append_log_message(log_message)
    pa         = self.proxy_association
    fkey       = pa.reflection.foreign_key
    fkey_value = pa.owner.id

    sql = "INSERT INTO #{self.table_name}"
    sql << " (tm, tm_usec, data, #{fkey})"
    sql << " VALUES(?, 0, ?, ?)"

    sql = pa.reflection.klass.send(:sanitize_sql, [sql, log_message.tm, log_message.log, fkey_value])
    connection.execute sql

    self.new tm: log_message.tm, tm_usec: 0, data: log_message.log
  end

end
