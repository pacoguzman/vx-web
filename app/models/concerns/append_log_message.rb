module AppendLogMessage

  def append_log_message(log_message)
    last_log     = self.last
    lines        = log_message.log.split(/(?<=\n)/) # keep new line
    created_logs = []
    updated_logs = []

    if last_log && last_log.data.index("\n").nil?
      first_line = lines.shift
      last_log.update_attribute :data, "#{last_log.data}#{first_line}"
      updated_logs << last_log
    end

    lines.each do |line|
      log = self.create! tm: log_message.tm, tm_usec: log_message.tm_usec, data: line
      created_logs << log
    end

    [created_logs, updated_logs]
  end

end
