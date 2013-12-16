class EnvLoader

  class << self
    def load!
      file = '/etc/vexor/ci'
      file = File.expand_path(file)

      if File.readable?(file)
        buf  = File.read(file)

        buf.split("\n").each do |line|
          next if line.strip.empty?

          env, value = line.split("=").map(&:strip)
          ::ENV[env] = value
        end
      end
    end
  end
end
