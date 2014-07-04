class ProjectsSerializer < ActiveModel::ArraySerializer

  def serializable_array
    @object.map do |item|
      ProjectSerializer.new(item, scope: self).serializable_hash
    end
  end

  def last_builds
    limit = 10
    @last_builds ||= begin
      query = %{
        SELECT builds.* FROM builds
        INNER JOIN (
          SELECT project_id, MAX(number) n
          FROM builds
          WHERE project_id IN (#{project_ids})
          GROUP BY project_id
        ) AS _b ON _b.project_id = builds.project_id AND (_b.n - #{limit}) < builds.number
        ORDER BY builds.project_id, builds.number DESC
      }.squish
      Build.find_by_sql(query).group_by{|b| b.project_id }
    end
  end

  private

    def project_ids
      object.map{|i| Project.connection.quote i.id }.join(",")
    end

end
