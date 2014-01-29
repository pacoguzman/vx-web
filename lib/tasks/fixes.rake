namespace :vx do
  namespace :fixes do

    task :user_repos_external_id do
      updated   = 0
      destroyed = 0
      UserRepo.transaction do
        UserIdentity.where(provider: "github").each do |ui|
          repos = nil
          ui.user_repos.where("external_id < 0").each do |ur|
            repos ||= ui.sc.repos
            repo = repos.select{|r| r.full_name == ur.full_name }.first
            if repo
              puts "#{repo.full_name} -> #{repo.id}"
              ur.update! external_id: repo.id
              total += 1
            end
          end
        end
        destroyed = UserRepo.where("external_id < 0").count
        UserRepo.where("external_id < 0").destroy_all
      end
      puts ""
      puts "DONE! #{updated} updated, #{destroyed} destroyed"
    end

    task all: [:environment, :user_repos_external_id]

  end
end
