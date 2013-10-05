class RemoveTmUsecFromJobLogs < ActiveRecord::Migration
  def change
    remove_column :job_logs, :tm_usec
  end
end
