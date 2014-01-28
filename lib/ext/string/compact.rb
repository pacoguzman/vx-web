class String
  def compact
    self.gsub(/\n/, ' ').gsub(/ +/, ' ').strip
  end
end
