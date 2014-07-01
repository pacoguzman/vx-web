class ProjectsSerializer < ActiveModel::ArraySerializer

  def serializable_array
    @object.map do |item|
      ProjectSerializer.new(item, scope: self).serializable_hash
    end
  end

  def last_builds
    @last_builds ||= begin
      query = %{
        SELECT builds.* FROM builds
        INNER JOIN
          (
            SELECT project_id, MAX(number) AS number
            FROM builds
            WHERE project_id in (#{project_ids.join(',')})
            GROUP BY project_id
          ) g
          ON g.project_id = builds.project_id AND g.number = builds.number
        ORDER BY builds.project_id
      }.squish
      Build.find_by_sql query
    end
  end

  private

    def project_ids
      object.map{|i| Project.connection.quote i.id }
    end

end
