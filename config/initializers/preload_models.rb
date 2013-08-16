Dir[Rails.root.join("app/models/*.rb")].each do |m|
  require m
end
