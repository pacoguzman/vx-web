Dir["#{Rails.root.join("lib/ext")}/**/*.rb"].each do |f|
  require f
end
