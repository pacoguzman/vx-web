module AppendLogMessage

  def append_log_message(log_message)
    pa         = self.proxy_association
    fkey       = pa.reflection.foreign_key
    fkey_value = pa.owner.id
    data       = log_message.log

    sql = "INSERT INTO #{self.table_name}"
    sql << " (tm, data, #{fkey})"
    sql << " VALUES(?, ?, ?)"

    sql = pa.reflection.klass.send(:sanitize_sql, [sql, log_message.tm, data, fkey_value])
    connection.execute sql

    self.new tm: log_message.tm, data: data
  end

end
