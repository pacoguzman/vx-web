Dir[Rails.root.join("lib/*.rb")].each do |f|
  require f
end

Dir["#{Rails.root.join("lib/ext")}/**/*.rb"].each do |f|
  require f
end
