# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

VxWeb::Application.load_tasks

namespace :travis do

  task :backend => ["db:migrate", :spec]
  task :frontend => ['karma:templates'] do
    karma = File.expand_path("node_modules/karma/bin/karma")
    exec "sh -c 'cd app/assets/javascripts && #{karma} start --single-run --color' "
  end
end

namespace :karma do
  task templates: :environment do
    require 'erb'
    tmpl = ERB.new(File.read Rails.root.join("app/assets/javascripts/templates.js.erb"))
    File.open(Rails.root.join("app/assets/javascripts/templates.compilled.js"), 'w') do |io|
      io.write tmpl.result
    end
  end

  task run: :templates do
    exec "sh -c 'cd app/assets/javascripts && karma start --single-run --color'"
  end

  task start: :templates do
    exec "sh -c 'cd app/assets/javascripts && karma start --color'"
  end
end
