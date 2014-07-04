class UserReposSerializer < ActiveModel::ArraySerializer

  def serializable_array
    @object.map do |item|
      UserRepoSerializer.new(item, scope: self).serializable_hash
    end
  end

  def same_name_projects
    @same_name_projects ||= begin
      query = %{
        SELECT id, name
          FROM projects
          WHERE
            projects.name IN (#{user_repo_names})
            AND
            projects.company_id = '#{company_id}'
      }.squish
      Project.find_by_sql query
    end
  end

  private

    def user_repo_names
      object.map do |o|
        UserRepo.connection.quote o.full_name
      end.join(",")
    end

    def company_id
      unless options[:scope].respond_to?(:default_company)
        raise ArgumentError, 'UserReposSerializer requires user in scope'
      end
      options[:scope].default_company.id
    end

end
