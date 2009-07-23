# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
config.action_mailer.raise_delivery_errors = false
config.action_mailer.default_url_options = { :host => 'site.thelongestday.net' }

SALT_FILE = File.join(RAILS_ROOT, '..', '..', 'shared', 'config', 'salt')  
SITE_SALT = File.exists?(SALT_FILE) ? File.read(SALT_FILE) : 'nosalt'
CERT_DIR = File.join(RAILS_ROOT, '..', '..', 'shared', 'config', 'x509')

PDF_DIR =  File.join(RAILS_ROOT, '..', '..', 'shared', 'pdf')
