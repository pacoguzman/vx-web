class UpdateLastBuildOnProjects < ActiveRecord::Migration
  def change
    execute "
      CREATE TEMPORARY TABLE tt_builds ON COMMIT DROP AS
        SELECT
          builds.project_id,
          builds.id,
          CASE
            WHEN builds.status = 2 THEN 'started'
            WHEN builds.status = 3 THEN 'passed'
            WHEN builds.status = 4 THEN 'failed'
            WHEN builds.status = 5 THEN 'errored'
          END AS status_name,
          builds.created_at
        FROM (
          SELECT project_id, MAX(number) AS number
          FROM builds
          WHERE status NOT IN (0,1)
          GROUP BY project_id) AS source
        INNER JOIN builds ON builds.project_id = source.project_id AND builds.number = source.number
        ORDER BY builds.project_id
    ".compact

    execute "
      UPDATE projects AS p
      SET
        last_build_id = b.id,
        last_build_status_name = b.status_name,
        last_build_at = b.created_at
      FROM tt_builds AS b
      WHERE p.id = b.project_id
    ".compact
  end
end
