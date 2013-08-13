puts "[PATCH] ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#supports_extensions? always be true"

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      def supports_extensions?
        true
      end
    end
  end
end
