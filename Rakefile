# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

CiWeb::Application.load_tasks

namespace :travis do

  task :backend => ["db:migrate", :spec]
  task :frontend do
    karma = File.expand_path("node_modules/karma/bin/karma")
    exec "sh -c 'cd app/assets/javascripts && #{karma} start --single-run --color' "
  end
end
