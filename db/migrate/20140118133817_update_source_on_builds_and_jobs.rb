class UpdateSourceOnBuildsAndJobs < ActiveRecord::Migration
  def change
    val = "---\nscript: /bin/true\n"
    val = ActiveRecord::Base.sanitize(val)
    execute "UPDATE builds SET source = #{val} WHERE source IS NULL"
    execute "UPDATE jobs SET source = #{val} WHERE source IS NULL"
  end
end
