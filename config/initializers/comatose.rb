Comatose.configure do |config|
  config.admin_title = "TLD"
  config.admin_sub_title = "Bork. Flail. Gusto"
  config.default_processor = :erb
  config.admin_includes << :punter_system
  config.admin_authorization = :admin_required
end
